#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : cycler
# Version       : v0.12.1
# Source repo   : https://github.com/matplotlib/cycler
# Tested on     : UBI:9.6
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Build Scripts Team <build-scripts@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - cycler is a pure Python library (PyPI: cycler) that provides a
#     composable cycle class for Matplotlib and other applications.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Upstream git tags use a "v" prefix (e.g., v0.12.1).
#   - Tests: pytest → 26 passed on Python 3.11/3.12.
#   - Tracking issue: LOZPY-168
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="cycler"
PACKAGE_URL="https://github.com/matplotlib/cycler"
NOARCH="true"

# Upstream git tags are prefixed with 'v' (e.g., v0.12.1)
PACKAGE_VERSION="${1:-v0.12.1}"
if [[ "${PACKAGE_VERSION}" != v* ]]; then
    PACKAGE_VERSION="v${PACKAGE_VERSION}"
fi

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Runs the upstream pytest suite.
# Expected: 26 passed.
# =============================================================================
custom_test_command() {
    pytest test_cycler.py -v
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
