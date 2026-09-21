#!/usr/bin/env python3
"""Enforce the minimum line coverage reported by an LCOV file."""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path


class CoverageError(ValueError):
    """Raised when an LCOV report is missing or internally inconsistent."""


@dataclass(frozen=True)
class Coverage:
    lines_found: int
    lines_hit: int

    @property
    def percent(self) -> float:
        if self.lines_found == 0:
            raise CoverageError("LCOV report contains no executable lines")
        return self.lines_hit * 100.0 / self.lines_found


def _parse_count(raw_value: str, field: str) -> int:
    try:
        value = int(raw_value)
    except ValueError as error:
        raise CoverageError(f"invalid {field} value: {raw_value!r}") from error
    if value < 0:
        raise CoverageError(f"{field} cannot be negative: {value}")
    return value


def parse_lcov(report: str) -> Coverage:
    """Parse per-file LF/LH values and return their aggregate line coverage."""

    total_lines = 0
    hit_lines = 0
    record_lines: int | None = None
    record_hits: int | None = None
    record_count = 0

    for raw_line in report.splitlines():
        line = raw_line.strip()
        if line.startswith("LF:"):
            if record_lines is not None:
                raise CoverageError("LCOV record contains duplicate LF field")
            record_lines = _parse_count(line[3:], "LF")
        elif line.startswith("LH:"):
            if record_hits is not None:
                raise CoverageError("LCOV record contains duplicate LH field")
            record_hits = _parse_count(line[3:], "LH")
        elif line == "end_of_record":
            if record_lines is None or record_hits is None:
                raise CoverageError("LCOV record is missing LF or LH")
            if record_hits > record_lines:
                raise CoverageError(
                    f"LCOV record has more hit lines than found lines: "
                    f"{record_hits}>{record_lines}"
                )
            total_lines += record_lines
            hit_lines += record_hits
            record_count += 1
            record_lines = None
            record_hits = None

    if record_lines is not None or record_hits is not None:
        raise CoverageError("LCOV report ends before end_of_record")
    if record_count == 0:
        raise CoverageError("LCOV report contains no complete file records")
    if total_lines == 0:
        raise CoverageError("LCOV report contains no executable lines")

    return Coverage(lines_found=total_lines, lines_hit=hit_lines)


def enforce_threshold(coverage: Coverage, minimum: float) -> Coverage:
    if not 0 <= minimum <= 100:
        raise CoverageError(f"minimum coverage must be between 0 and 100: {minimum}")
    if coverage.percent < minimum:
        raise CoverageError(
            f"coverage {coverage.percent:.2f}% is below minimum {minimum:.2f}%"
        )
    return coverage


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path, help="path to an LCOV report")
    parser.add_argument(
        "--minimum",
        type=float,
        default=80.0,
        help="minimum line coverage percentage (default: 80)",
    )
    args = parser.parse_args(argv)

    try:
        coverage = parse_lcov(args.report.read_text(encoding="utf-8"))
        enforce_threshold(coverage, args.minimum)
    except (OSError, CoverageError) as error:
        print(f"Coverage check failed: {error}", file=sys.stderr)
        return 1

    print(
        f"Coverage: {coverage.percent:.2f}% "
        f"({coverage.lines_hit}/{coverage.lines_found} lines), "
        f"minimum: {args.minimum:.2f}%"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
