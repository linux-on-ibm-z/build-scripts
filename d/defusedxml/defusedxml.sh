#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : defusedxml
# Version       : v0.7.1
# Source repo   : https://github.com/tiran/defusedxml
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
#                 platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - python tests.py uses unittest.makeSuite() which was removed in 3.13.
#   - For 3.13+, pytest is used with deselects for:
#       BaseTests      : abstract base class, pytest collects it by mistake
#       TestDefusedLxml: requires lxml (not installed), tests are optional
#       test_html_arg  : DeprecationWarning no longer raised in newer Python
#       test_main      : calls unittest.makeSuite() directly, removed in 3.13
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="defusedxml"
PACKAGE_VERSION="${1:-v0.7.1}"
PACKAGE_URL="https://github.com/tiran/defusedxml"

NOARCH="true"

RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

custom_test_command() {
    cd /workspace/defusedxml
    PYMINOR="${PYTHON_VERSION##*.}"
    if [ "${PYMINOR}" -ge 13 ]; then
        pytest tests.py \
            --deselect=tests.py::BaseTests \
            --deselect=tests.py::TestDefusedLxml \
            --deselect=tests.py::TestDefusedElementTree::test_html_arg \
            --deselect=tests.py::TestDefusedcElementTree::test_html_arg \
            --deselect=tests.py::test_main
    else
        python tests.py
    fi
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
