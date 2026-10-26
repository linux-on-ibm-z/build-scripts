#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : pytest
# Version       : 8.3.5
# Source repo   : https://github.com/pytest-dev/pytest
# Tested on     : UBI:9.6
# Language      : Python
# Ci-Check      : True
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
#   - pytest is a pure Python testing framework (PyPI: pytest).
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Upstream git tags have no 'v' prefix for recent versions (e.g., 8.3.5).
#   - Tests: pytest testing/
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="pytest"
PACKAGE_URL="https://github.com/pytest-dev/pytest"
NOARCH="true"

PACKAGE_VERSION="${1:-8.3.5}"
PACKAGE_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Installs test dependencies and runs core unit tests.
# =============================================================================
custom_test_command() {
    log_info "Installing test dependencies..."
    pip install iniconfig packaging pluggy
    log_info "Running pytest self-test suite..."
    pytest testing/test_parseopt.py testing/test_config.py -v
    log_info "pytest test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
