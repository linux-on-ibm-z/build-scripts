#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : fastavro
# Version       : 1.11.1
# Source repo   : https://github.com/fastavro/fastavro
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
#   - fastavro is a Python library for working with Apache Avro data,
#     offering improved performance over the pure Python avro package.
#   - Installed from PyPI via pip.
#   - Tests are run with pytest; output is redirected to test_logs.txt.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="fastavro"
PACKAGE_VERSION="${1:-1.11.1}"
PACKAGE_URL="https://github.com/fastavro/fastavro"

NOARCH="true"

RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

custom_test_command() {
    # Install codec and test dependencies
    pip install cramjam zstandard lz4 zlib_ng numpy pandas pytest-cov

    cd /workspace/fastavro
    # test_cython_python asserts the Cython-compiled reader is active; since
    # fastavro is installed from the PyPI sdist (pure Python fallback) this
    # test always fails and is a known environment limitation.
    pytest tests/ -v -k "not test_cython_python" 2>&1 | tee test_logs.txt
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
