#!/usr/bin/env python3
"""Smoke-test the installed aws-c-common wheel.

Usage: python aws_c_common_smoke.py <expected-version>
  e.g. python aws_c_common_smoke.py 1.0.0
"""
import sys
from importlib.metadata import version
from pathlib import Path

import aws_c_common

expected = sys.argv[1]
installed = version("aws-c-common")
assert installed == expected, f"version mismatch: installed={installed!r}, expected={expected!r}"
assert aws_c_common.__version__ == installed, \
    f"__version__ mismatch: {aws_c_common.__version__!r} != {installed!r}"

origin = Path(aws_c_common.__file__).resolve()
assert "site-packages" in origin.parts, f"unexpected install path: {origin}"

# Verify the shared library is present inside the wheel's package directory
so_files = list(origin.parent.glob("libaws-c-common.so*"))
assert so_files, f"libaws-c-common.so* not found under {origin.parent}"

print(f"aws-c-common installed wheel version: {installed}")
print(f"  location : {origin.parent}")
print(f"  .so files: {[f.name for f in so_files]}")
