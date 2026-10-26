#!/bin/bash -e

# -----------------------------------------------------------------------------
# Package       : jinja2
# Version       : 3.1.6
# Source repo   : https://github.com/pallets/jinja
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
#                 platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - jinja2 is a fast, expressive templating engine for Python.
#   - The package is pure Python; NOARCH=true is used.
#   - trio is installed in custom_test_command() because the async test variants
#     (e.g. test_basic_async[trio]) require it at collection time.
#   - test_elif_deep (tests/test_core_tags.py::TestIfCondition::test_elif_deep)
#     hits a RecursionError on Python 3.12 and 3.13 because the deeply nested
#     elif chain exceeds Python's compile-time recursion limit. The test passes
#     on 3.10, 3.11, and 3.14. custom_test_command() conditionally deselects
#     it on affected versions.
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="jinja2"
PACKAGE_VERSION="${1:-3.1.6}"
PACKAGE_URL="https://github.com/pallets/jinja"

NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# test_elif_deep causes RecursionError on Python 3.12 and 3.13 only (see Notes).
# =============================================================================
custom_test_command() {
    pip install trio

    if python -c "import sys; exit(0 if sys.version_info[:2] in ((3,12),(3,13)) else 1)" 2>/dev/null; then
        pytest --deselect=tests/test_core_tags.py::TestIfCondition::test_elif_deep
    else
        pytest
    fi
}

# =============================================================================
# Source the Python template to execute the build and test workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
