#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : jmespath
# Version       : 1.0.1
# Source repo   : https://github.com/jmespath/jmespath.py
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Aritrika Ghosh <aritrika@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - jmespath is a pure-Python library
#   - Published noarch wheel installed via NOARCH, not rebuilt from source
#   - No compiled extensions; no extra system packages needed
#   - extra/test_hypothesis.py is skipped: hypothesis is not pinned for
#     Python >= 3.10 in requirements.txt and tox uses nose which is
#     incompatible with Python 3.10+ (collections.Callable removed)
#   - requirements.txt pins pytest==6.2.5 and wheel==0.24.0; both are
#     overridden in pre_test to work on Python 3.14+ (ast.Str removed)
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# PACKAGE_VERSION defaults to v0.9.0, overridable as $1
# =============================================================================
PACKAGE_NAME="jmespath"
PACKAGE_VERSION="${1:-1.0.1}"
PACKAGE_URL="https://github.com/jmespath/jmespath.py"

# =============================================================================
# OPTIONAL: Build configuration
# Pure-Python package; install directly from PyPI
# =============================================================================
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# No extra system packages needed; the container toolchain is sufficient
# =============================================================================
RH_DEP_PKGS=""

# =============================================================================
# CUSTOM TEST: upgrade pytest after requirements.txt downgrades it to 6.2.5
# (which uses ast.Str, removed in Python 3.14), then run pytest skipping the
# hypothesis file (not installed for Python >= 3.10) and bypassing
# tox/nosetests (nose is broken on Python 3.10+ due to removal of
# collections.Callable).
# =============================================================================
custom_test_command() {
    pip install --upgrade "pytest>=7.0" "wheel>=0.40"
    python -m pytest --ignore=extra/test_hypothesis.py -o "addopts="
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
