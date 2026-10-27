#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : traitlets
# Version       : 5.14.3
# Source repo   : https://github.com/ipython/traitlets
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
#   - traitlets is a pure Python library (PyPI: traitlets) enabling configuration
#     and type-checking for Python objects (powers IPython and Jupyter).
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Upstream git tags use a 'v' prefix (e.g., v5.14.3).
#   - Test deps: pytest, pytest-mock, argcomplete.
#   - Tests: pytest tests/
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="traitlets"
PACKAGE_URL="https://github.com/ipython/traitlets"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v5.14.3)
PACKAGE_VERSION="${1:-5.14.3}"
# Strip leading 'v' for PyPI / consistency
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
# Installs test dependencies and runs the upstream pytest suite.
# =============================================================================
custom_test_command() {
    log_info "Installing test dependencies..."
    pip install "pytest>=7.0,<8.2" pytest-mock "argcomplete>=3.0.3"
    log_info "Running traitlets test suite..."
    pytest tests/ -v
    log_info "traitlets test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
