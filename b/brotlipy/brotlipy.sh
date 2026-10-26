#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : brotlipy
# Version       : v0.7.0
# Source repo   : https://github.com/python-hyper/brotlicffi
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
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="brotlipy"
PACKAGE_VERSION="${1:-v0.7.0}"
PACKAGE_URL="https://github.com/python-hyper/brotlicffi"
CLONE_DIR="brotlicffi"

NOARCH="true"

RH_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv build-essential"
SLES_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"

custom_test_command() {
    pip install hypothesis
    cd /workspace/brotlicffi
    pytest test/ --ignore=libbrotli \
        --deselect=test/test_simple_compression.py::test_streaming_compression \
        --deselect=test/test_simple_compression.py::test_streaming_compression_flush
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"

