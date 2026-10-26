#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : tornado
# Version       : v6.4.2
# Source repo   : https://github.com/tornadoweb/tornado
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
#   - Python web framework with a native C extension (tornado.speedups)
#   - Compiled extension makes the wheel architecture-specific (cp38-abi3)
#   - build-system requires only setuptools and wheel; both are in the template venv
#   - Upstream test command: python -m tornado.test
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="tornado"
PACKAGE_VERSION="${1:-v6.4.2}"
PACKAGE_URL="https://github.com/tornadoweb/tornado"

# REQUIRED: Dependencies
RH_DEP_PKGS="gcc git python3 python3-devel"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# CALLBACK: post_clone: after the clone, worktree at PACKAGE_VERSION
post_clone() {
    if [[ -f "${SCRIPT_DIR}/patches/${PACKAGE_NAME}.patch" ]]; then
        log_info "Applying generated patch..."
        git apply "${SCRIPT_DIR}/patches/${PACKAGE_NAME}.patch"
    fi
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    # --fail-if-logs=false is upstream's own setting for occasional OpenSSL 3 log lines
    # ("error on read: [SYS] unknown error") that otherwise turn an all-pass run
    # into exit 1 (pyproject.toml [tool.cibuildwheel.windows] test-command).
    if ! LOGNAME="${test_user}" python -m tornado.test --fail-if-logs=false; then
        echo "------------------${PACKAGE_NAME}:Test_fails-------------------------------------"
        return 1
    fi
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
