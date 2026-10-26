#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : imageio
# Version       : v2.37.0
# Source repo   : https://github.com/imageio/imageio.git
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
#   - fsspec[http] and requests are needed by the upstream test suite
#   - Pure-Python library from imageio, no compiled extension
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="imageio"
PACKAGE_VERSION="${1:-v2.37.0}"
PACKAGE_URL="https://github.com/imageio/imageio.git"

# REQUIRED: Dependencies
# libwebp-devel: required to compile Pillow with WEBP codec support;
# the pre-built PyPI wheel for s390x lacks it, causing test_webp_remote to fail.
RH_DEP_PKGS="libwebp-devel"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# CALLBACK: post_clone: after the clone, worktree at PACKAGE_VERSION
post_clone() {
    if [[ -f "${SCRIPT_DIR}/patches/${PACKAGE_NAME}.patch" ]]; then
        log_info "Applying generated patch..."
        git apply "${SCRIPT_DIR}/patches/${PACKAGE_NAME}.patch"
    fi
}

# CALLBACK: pre_test: installs test prerequisites
pre_test() {
    # Install test dependencies and force-reinstall Pillow from source so it links
    # against system libwebp-devel; the pre-built s390x manylinux wheel lacks WEBP support.
    pip install fsspec[http] requests imageio[ffmpeg] Pillow
}

# CALLBACK: custom_test_command
#   Run pytest without --import-mode=importlib so that tests/ is added to
# sys.path and bare `from conftest import ...` resolves (devtest loz_test.sh
custom_test_command() {
    pytest
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
