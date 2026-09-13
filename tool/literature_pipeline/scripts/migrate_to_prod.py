#!/usr/bin/env python3
"""Compatibility entry point for migrating extracted candidates to assets.

Legacy seed JSON files were removed from the application. This command now
uses the same dry-run-first, provenance-preserving asset pipeline as
build_db.py instead of manufacturing bibliographic evidence.
"""

from build_assets import main


if __name__ == "__main__":
    main()
