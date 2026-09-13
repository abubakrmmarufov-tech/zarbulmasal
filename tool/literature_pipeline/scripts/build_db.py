#!/usr/bin/env python3
"""Compatibility entry point for the current literature asset builder.

The old implementation generated deleted Dart seed files. Keep this command
name for existing notes and automation, but delegate to build_assets.py.
"""

from build_assets import main


if __name__ == "__main__":
    main()
