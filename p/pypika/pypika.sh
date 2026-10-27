#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : pypika
# Version       : 0.51.1
# Source repo   : https://github.com/kayak/pypika
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
#   - pypika is a pure Python SQL query builder library (PyPI: PyPika).
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Upstream git tags use a 'v' prefix (e.g., v0.51.1).
#   - Test deps: unittest/pytest, parameterised.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="pypika"
PACKAGE_URL="https://github.com/kayak/pypika"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v0.51.1)
PACKAGE_VERSION="${1:-0.51.1}"
PACKAGE_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# CALLBACK: pre_clone
# Ensure PACKAGE_VERSION carries the 'v' prefix for git checkout
# =============================================================================
pre_clone() {
    if [[ "${PACKAGE_VERSION}" != v* ]]; then
        PACKAGE_VERSION="v${PACKAGE_VERSION}"
    fi
}

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Installs test dependencies and runs the upstream test suite.
# =============================================================================
custom_test_command() {
    log_info "Installing test dependencies..."
    pip install parameterized unittest-xml-reporting
    log_info "Running pypika test suite..."
    python3 setup.py test || pytest pypika/tests/ -v
    log_info "pypika test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
