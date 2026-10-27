#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : tensorboard-plugin-wit
# Version       : 1.8.1
# Source repo   : https://github.com/PAIR-code/what-if-tool
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
#   - tensorboard-plugin-wit is a pure Python TensorBoard plugin (PyPI:
#     tensorboard-plugin-wit) providing the What-If Tool for model analysis
#     and fairness exploration directly inside TensorBoard.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - No runtime dependencies declared on PyPI.
#   - Upstream git tags use a 'v' prefix (e.g., v1.8.1); the bare version
#     (e.g., 1.8.1) is used for the PyPI install.
#   - Note: PyPI versions 1.6.0.post2/post3 exist; 1.8.1 is the latest stable.
#   - Tests: pytest witwidget/tests/ -x -q (upstream test directory).
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="tensorboard-plugin-wit"
PACKAGE_URL="https://github.com/PAIR-code/what-if-tool"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v1.8.1).
PACKAGE_VERSION="${1:-1.8.1}"
# Strip leading 'v' so we work with a bare number (e.g., 1.8.1)
PACKAGE_VERSION="${PACKAGE_VERSION#v}"
# Pin PYPI_VERSION now, before pre_clone adds the 'v' prefix for git checkout.
PYPI_VERSION="${PACKAGE_VERSION}"

# =============================================================================
# CALLBACK: pre_clone
# Add the 'v' prefix required by the upstream git tag (e.g., 1.8.1 → v1.8.1).
# =============================================================================
pre_clone() {
    PACKAGE_VERSION="v${PACKAGE_VERSION}"
}

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Installs test dependencies then runs the tensorboard-plugin-wit test suite.
# Expected: all tests pass on Python 3.10+.
# =============================================================================
custom_test_command() {
    log_info "Installing tensorboard-plugin-wit test dependencies..."
    pip install pytest absl-py
    log_info "Running tensorboard-plugin-wit test suite..."
    pytest witwidget/tests/ -x -q
    log_info "tensorboard-plugin-wit test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
