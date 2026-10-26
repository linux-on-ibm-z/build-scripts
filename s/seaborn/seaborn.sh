#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : seaborn
# Version       : v0.13.2
# Source repo   : https://github.com/mwaskom/seaborn.git
# Tested on     : UBI:9.8
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Sai-Sindhuri-Avulamanda <Sai.Sindhuri.Avulamanda@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - Statistical data visualization in Python
#   - Dependencies installed via pip in pre_build and pre_test
#   - Pure-Python library from mwaskom, no compiled extension
#   - Published noarch wheel installed via NOARCH, not rebuilt
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="seaborn"
PACKAGE_VERSION="${1:-v0.13.2}"
PACKAGE_URL="https://github.com/mwaskom/seaborn.git"

# REQUIRED: Dependencies
RH_DEP_PKGS=""
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# CALLBACK: post_clone: after the clone, worktree at PACKAGE_VERSION
post_clone() {
    if [[ -f "${SCRIPT_DIR}/patches/${PACKAGE_NAME}.patch" ]]; then
        log_info "Applying generated patch..."
        git apply "${SCRIPT_DIR}/patches/${PACKAGE_NAME}.patch"
    fi
}

# CALLBACK: pre_build: in the build env, before the build
pre_build() {
    pip install "flit_core<4,>=3.2"
}

# CALLBACK: pre_test: installs test prerequisites
pre_test() {
    # flit_core: seaborn's pyproject.toml build-backend; pip needs it in .venv-test to install from source
    # numpy<2: avoid breaking API changes in seaborn 0.13.2 tests (np.in1d removed in numpy 2.x)
    # pandas>=2.2,<3: pandas<2.2 resolves to 2.1.4 which has no cp314 wheel and fails to compile
    #   against Python 3.14 (_PyLong_AsByteArray signature changed); 2.2.x ships a pre-built wheel
    # matplotlib>=3.10,<3.11: >=3.10 avoids deepcopy RecursionError on Python 3.14; <3.11 avoids
    #   exp-based log transform (introduces sub-ULP rounding breaking test_log_scale) and avoids
    #   changed RcParams error message format (breaking test_theme_validation)
    pip install "flit_core<4,>=3.2" "pytest<8" "numpy<2" "pandas>=2.2,<3" scipy statsmodels "matplotlib>=3.10,<3.11"
}

export PIP_NO_CACHE_DIR=1

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
