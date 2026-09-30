#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : ipywidgets
# Version       : 8.1.5
# Source repo   : https://github.com/jupyter-widgets/ipywidgets
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
#   - ipywidgets provides interactive HTML widgets for Jupyter notebooks
#     and the IPython kernel.
#   - The Python package lives under python/ipywidgets/ inside the repo root.
#   - The package is a pure Python package.
#   - The package is marked as NOARCH and is installed from PyPI.
#   - No custom build command is required for this NOARCH package.
#   - Test dependencies are installed before running the test suite.
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="ipywidgets"
PACKAGE_VERSION="${1:-8.1.5}"
GIT_TAG="${PACKAGE_VERSION}"
PACKAGE_URL="https://github.com/jupyter-widgets/ipywidgets"

NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

# =============================================================================
# CALLBACK: Pre-test
# Install dependencies required by the test suite.
# =============================================================================
pre_test() {
    log_info "Installing test dependencies..."

    pip install \
        pytz \
        ipykernel \
        jsonschema
}

# =============================================================================
# Source the Python template to execute the build and test workflow
# =============================================================================
source "${SCRIPT_DIR}/../../templates/python.sh"
