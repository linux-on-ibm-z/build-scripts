#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : nbdime
# Version       : 4.0.1
# Source repo   : https://github.com/jupyter/nbdime
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
#   - nbdime provides tools for diffing and merging Jupyter Notebooks.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Upstream git tags use bare version numbers (e.g., 4.0.1).
#   - Tests: pytest --pyargs nbdime → runs Python unit and integration tests.
#     custom_test_command() configures git credentials (required by git diff/merge tests)
#     and installs test dependencies.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="nbdime"
PACKAGE_URL="https://github.com/jupyter/nbdime"
NOARCH="true"

# Upstream git tags use bare version numbers (e.g., 4.0.1)
PACKAGE_VERSION="${1:-4.0.1}"
PACKAGE_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Configures git credentials (needed for nbdime git integration tests) and
# installs test dependencies.
# Runs test suite against installed package using pytest --pyargs.
# =============================================================================
custom_test_command() {
    log_info "Configuring git, installing test dependencies and running nbdime test suite..."
    git config --global user.email "build-scripts@ibm.com"
    git config --global user.name "Build Scripts Team"
    pip install pytest-timeout pytest-tornado tabulate requests pytest pytest-cov jsonschema mock "jupyter-server[test]"
    log_info "Running nbdime test suite..."
    pytest -l -v --pyargs nbdime
    log_info "nbdime test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
 
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
