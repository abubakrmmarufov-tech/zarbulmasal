#!/usr/bin/env python3
"""Verify native ELF load-segment alignment inside an Android App Bundle."""

from __future__ import annotations

import argparse
import struct
import sys
import zipfile
from pathlib import Path


MIN_PAGE_ALIGNMENT = 0x4000
ELF_MAGIC = bytes((0x7F,)) + b"ELF"


def load_segment_alignments(data: bytes) -> tuple[int, ...]:
    """Return PT_LOAD p_align values from an ELF32 or ELF64 binary."""
    if len(data) < 16 or data[:4] != ELF_MAGIC:
        raise ValueError("not an ELF binary")

    elf_class = data[4]
    endian_marker = data[5]
    endian = {1: "<", 2: ">"}.get(endian_marker)
    if endian is None:
        raise ValueError(f"unsupported ELF byte order: {endian_marker}")

    if elf_class == 2:
        if len(data) < 64:
            raise ValueError("truncated ELF64 header")
        phoff = struct.unpack_from(endian + "Q", data, 32)[0]
        phentsize = struct.unpack_from(endian + "H", data, 54)[0]
        phnum = struct.unpack_from(endian + "H", data, 56)[0]
        minimum_phentsize = 56
        align_offset = 48
        align_format = "Q"
    elif elf_class == 1:
        if len(data) < 52:
            raise ValueError("truncated ELF32 header")
        phoff = struct.unpack_from(endian + "I", data, 28)[0]
        phentsize = struct.unpack_from(endian + "H", data, 42)[0]
        phnum = struct.unpack_from(endian + "H", data, 44)[0]
        minimum_phentsize = 32
        align_offset = 28
        align_format = "I"
    else:
        raise ValueError(f"unsupported ELF class: {elf_class}")

    if phentsize < minimum_phentsize:
        raise ValueError(f"truncated program header entries: {phentsize}")

    alignments: list[int] = []
    for index in range(phnum):
        entry_offset = phoff + index * phentsize
        entry_end = entry_offset + minimum_phentsize
        if entry_offset < 0 or entry_end > len(data):
            raise ValueError("program header extends beyond ELF binary")
        program_type = struct.unpack_from(endian + "I", data, entry_offset)[0]
        if program_type == 1:  # PT_LOAD
            alignments.append(
                struct.unpack_from(endian + align_format, data, entry_offset + align_offset)[0]
            )

    if not alignments:
        raise ValueError("ELF binary has no PT_LOAD segments")
    return tuple(alignments)


def verify_bundle(bundle_path: Path) -> list[tuple[str, tuple[int, ...]]]:
    """Validate every native library stored in the bundle's base module."""
    with zipfile.ZipFile(bundle_path) as archive:
        native_entries = sorted(
            name
            for name in archive.namelist()
            if name.startswith("base/lib/") and name.endswith(".so")
        )
        if not native_entries:
            raise ValueError("bundle contains no base-module native libraries")

        verified: list[tuple[str, tuple[int, ...]]] = []
        for name in native_entries:
            alignments = load_segment_alignments(archive.read(name))
            invalid = [
                alignment
                for alignment in alignments
                if alignment < MIN_PAGE_ALIGNMENT or alignment % MIN_PAGE_ALIGNMENT != 0
            ]
            if invalid:
                values = ", ".join(hex(value) for value in alignments)
                raise ValueError(
                    f"{name} has non-16KB PT_LOAD alignment: {values}"
                )
            verified.append((name, alignments))
        return verified


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bundle", type=Path)
    args = parser.parse_args()

    try:
        verified = verify_bundle(args.bundle)
    except (OSError, ValueError, zipfile.BadZipFile) as error:
        print(f"Android App Bundle native alignment verification failed: {error}", file=sys.stderr)
        return 1

    print(f"Verified 16 KB native alignment for {len(verified)} libraries:")
    for name, alignments in verified:
        values = ", ".join(hex(value) for value in alignments)
        print(f"  {name}: PT_LOAD p_align={values}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
