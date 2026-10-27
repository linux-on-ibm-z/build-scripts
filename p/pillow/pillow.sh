#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : pillow
# Version       : 11.1.0
# Source repo   : https://github.com/python-pillow/Pillow
# Tested on     : UBI:9.6
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
#   - C library with Python bindings
#   - Compiled extension makes the wheel architecture-specific
#   - Built by the in-tree PEP 517 backend under _custom_build/
#   - No extra system packages needed (container toolchain suffices)
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="pillow"
PACKAGE_VERSION="${1:-11.1.0}"
PACKAGE_URL="https://github.com/python-pillow/Pillow"

# REQUIRED: Dependencies
RH_DEP_PKGS=""
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# CALLBACK: post_clone: after the clone, worktree at PACKAGE_VERSION
post_clone() {
    if [[ "${PYTHON_VERSION}" == "3.14" && -f "${SCRIPT_DIR}/patches/pillow-py3.14.patch" ]]; then
        log_info "Applying py3.14 patch..."
        git apply "${SCRIPT_DIR}/patches/pillow-py3.14.patch"
    fi
}

# CALLBACK: pre_build: in the build env, before the build
pre_build() {
    rm -f dist/*.whl
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
