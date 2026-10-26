#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : scipy
# Version       : v1.16.2
# Source repo   : https://github.com/scipy/scipy
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
#   - Scientific Python library with Cython/C/Fortran native extensions
#   - Meson-python build backend; pyproject.toml [build-system].requires installed in pre_build()
#   - Submodules (BLAS/LAPACK stubs, Boost headers) required before build and test
#   - Cython-based Python library from scipy
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="scipy"
PACKAGE_VERSION="${1:-v1.16.2}"
PACKAGE_URL="https://github.com/scipy/scipy"

# REQUIRED: Dependencies
# gmp-devel provides gmp.h required to build gmpy2 (listed in requirements/test.txt)
RH_DEP_PKGS="gmp-devel"
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
    git submodule update --init --recursive
    # Pin to the upper bounds declared in pyproject.toml [build-system].requires;
    # requirements/build.txt has no upper bounds so pip resolves newer incompatible versions.
    pip install \
        "meson-python>=0.15.0,<0.21.0" \
        "Cython>=3.0.8,<3.2.0" \
        "pybind11>=2.13.2,<3.1.0" \
        "pythran>=0.14.0,<0.19.0" \
        ninja numpy
}

# CALLBACK: pre_test: installs test prerequisites
pre_test() {
    git submodule update --init --recursive
    pip install -r requirements/test.txt
    pip install "pythran>=0.14.0,<0.19.0" "pybind11>=2.13.2,<3.1.0" meson meson-python ninja click doit pydevtool rich_click "numpy<2.5"
    # dev.py imports click, doit, and pydevtool at module level (lines 121+); pydevtool/cli.py imports rich_click at line 107
    # pybind11 needed in .venv-test: dev.py test calls meson setup which uses pybind11-config from this venv
    # numpy>=2.5 emits DeprecationWarning for array.shape assignment; pytest.ini filterwarnings=error turns it fatal
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    python dev.py test -j "$(nproc)"
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
