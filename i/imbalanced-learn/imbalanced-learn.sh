#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : imbalanced-learn
# Version       : 0.13.0
# Source repo   : https://github.com/scikit-learn-contrib/imbalanced-learn
# Tested on     : UBI:9.6
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Viddya K <viddya.k@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# PACKAGE_VERSION defaults to 0.13.0, overridable as $1
# =============================================================================
PACKAGE_NAME="imbalanced-learn"
PACKAGE_VERSION="${1:-0.13.0}"
PACKAGE_URL="https://github.com/scikit-learn-contrib/imbalanced-learn"

# =============================================================================
# OPTIONAL: Build configuration
# =============================================================================
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# System packages needed for building imbalanced-learn
# =============================================================================
RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

# =============================================================================
# OPTIONAL: Build configuration
# =============================================================================
PYPI_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# CALLBACK: pre_test
# Installs test prerequisites before the test phase
# =============================================================================
pre_test() {
    # Keep the release's tests on contemporary numerical/scikit-learn APIs.
    python -m pip install "imbalanced-learn[tests]==${PYPI_VERSION}" \
        'numpy>=1.24.3,<2' 'scipy>=1.10.1,<1.15' \
        'scikit-learn==1.5.2' 'sklearn-compat>=0.1,<0.2'
}

# =============================================================================
# CALLBACK: custom_test_command
# Replaces the template's default test command
# =============================================================================
custom_test_command() {
    local tests="${PWD}/imblearn"
    (cd /tmp && python -m pytest "${tests}" --import-mode=importlib -o "addopts=" -q)
}

# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
