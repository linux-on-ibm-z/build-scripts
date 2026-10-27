#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : sklearn-pandas
# Version       : 2.2.0
# Source repo   : https://github.com/scikit-learn-contrib/sklearn-pandas
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
#   - sklearn-pandas is a pure Python library (PyPI: sklearn-pandas) that
#     provides a bridge between scikit-learn's transformer API and pandas
#     DataFrames via the DataFrameMapper class.
#   - Pure Python wheel (py2.py3-none-any) — NOARCH=true, installed from PyPI.
#   - Runtime deps: scikit-learn>=0.23.0, scipy>=1.5.1, pandas>=1.1.4,
#     numpy>=1.18.1.
#   - Upstream git tags use a 'v' prefix (e.g., v2.2.0); the bare version
#     (e.g., 2.2.0) is used for the PyPI install.
#   - Tests: pytest tests/ -x -q.
#     Expected: all tests pass on Python 3.10+ with standard scientific stack.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="sklearn-pandas"
PACKAGE_URL="https://github.com/scikit-learn-contrib/sklearn-pandas"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v2.2.0).
PACKAGE_VERSION="${1:-2.2.0}"
# Strip leading 'v' so we work with a bare number (e.g., 2.2.0)
PACKAGE_VERSION="${PACKAGE_VERSION#v}"
# Pin PYPI_VERSION now, before pre_clone adds the 'v' prefix for git checkout.
PYPI_VERSION="${PACKAGE_VERSION}"

# =============================================================================
# CALLBACK: pre_clone
# Add the 'v' prefix required by the upstream git tag (e.g., 2.2.0 → v2.2.0).
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
# Installs runtime and test dependencies then runs the sklearn-pandas test suite.
# Expected: all tests pass on Python 3.10+ with standard scientific stack.
# =============================================================================
custom_test_command() {
    log_info "Installing sklearn-pandas test dependencies..."
    pip install pytest \
        "scikit-learn>=0.23.0" "scipy>=1.5.1" \
        "pandas>=1.1.4" "numpy>=1.18.1"
    log_info "Running sklearn-pandas test suite..."
    pytest tests/ -x -q
    log_info "sklearn-pandas test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
