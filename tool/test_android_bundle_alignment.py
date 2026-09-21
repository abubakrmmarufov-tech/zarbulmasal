import struct
import tempfile
import unittest
import zipfile
from pathlib import Path

try:
    from tool.verify_android_bundle_alignment import (
        load_segment_alignments,
        verify_bundle,
    )
except ModuleNotFoundError as error:
    # Keep direct `python3 tool/test_android_bundle_alignment.py` execution
    # useful for local release debugging, while CI continues to import this
    # file as the `tool.test_android_bundle_alignment` module.
    if error.name != "tool":
        raise
    from verify_android_bundle_alignment import load_segment_alignments, verify_bundle


def synthetic_elf64(*alignments):
    header_size = 64
    program_header_size = 56
    data = bytearray(header_size + program_header_size * len(alignments))
    data[:4] = bytes((0x7F,)) + b"ELF"
    data[4] = 2  # ELF64
    data[5] = 1  # little-endian
    struct.pack_into("<Q", data, 32, header_size)
    struct.pack_into("<H", data, 54, program_header_size)
    struct.pack_into("<H", data, 56, len(alignments))
    for index, alignment in enumerate(alignments):
        offset = header_size + index * program_header_size
        struct.pack_into("<I", data, offset, 1)  # PT_LOAD
        struct.pack_into("<Q", data, offset + 48, alignment)
    return bytes(data)


class AndroidBundleAlignmentTest(unittest.TestCase):
    def test_load_segment_alignments_supports_16kb_and_larger(self):
        self.assertEqual(
            load_segment_alignments(synthetic_elf64(0x4000, 0x10000)),
            (0x4000, 0x10000),
        )

    def test_bundle_rejects_native_library_below_16kb_alignment(self):
        with tempfile.TemporaryDirectory() as directory:
            bundle = Path(directory) / "bad.aab"
            with zipfile.ZipFile(bundle, "w") as archive:
                archive.writestr("base/lib/arm64-v8a/libbad.so", synthetic_elf64(0x1000))

            with self.assertRaisesRegex(ValueError, "non-16KB"):
                verify_bundle(bundle)


if __name__ == "__main__":
    unittest.main()
