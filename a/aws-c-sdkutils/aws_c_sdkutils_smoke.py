#!/usr/bin/env python3
"""Smoke-test the installed aws-c-sdkutils wheel.

Usage: python aws_c_sdkutils_smoke.py <expected-version>
  e.g. python aws_c_sdkutils_smoke.py 0.1.6
"""
import sys
from importlib.metadata import version
from pathlib import Path

import aws_c_sdkutils

expected = sys.argv[1]
installed = version("aws-c-sdkutils")
assert installed == expected, f"version mismatch: installed={installed!r}, expected={expected!r}"
assert aws_c_sdkutils.__version__ == installed, \
    f"__version__ mismatch: {aws_c_sdkutils.__version__!r} != {installed!r}"

origin = Path(aws_c_sdkutils.__file__).resolve()
assert "site-packages" in origin.parts, f"unexpected install path: {origin}"

# Verify the shared library is present inside the wheel's package directory
so_files = list(origin.parent.glob("libaws-c-sdkutils.so*"))
assert so_files, f"libaws-c-sdkutils.so* not found under {origin.parent}"

print(f"aws-c-sdkutils installed wheel version: {installed}")
print(f"  location : {origin.parent}")
print(f"  .so files: {[f.name for f in so_files]}")
