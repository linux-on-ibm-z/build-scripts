#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : typing_extensions
# Version       : 4.13.1
# Source repo   : https://github.com/python/typing_extensions
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
#   - Pure-Python library from python, no compiled extension
#   - No extra system packages needed (container toolchain suffices)
#   - Custom callbacks: post_clone, pre_build, pre_test
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="typing_extensions"
PACKAGE_VERSION="${1:-4.13.1}"
PACKAGE_URL="https://github.com/python/typing_extensions"

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

# CALLBACK: pre_build: install build-time python dependencies
pre_build() {
    pip install "flit_core>=3.11,<4"
}

# CALLBACK: pre_test: installs test prerequisites
pre_test() {
    # _typed_dict_test_helper is a single-file test helper shipped in src/;
    # it is not a package so pip-install doesn't apply — copy it directly into
    # the active venv's site-packages so pytest can import it.
    cp src/_typed_dict_test_helper.py \
        "$(python3 -c 'import site; print(site.getsitepackages()[0])')/"
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
