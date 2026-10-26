#!/bin/bash -e
# ----------------------------------------------------------------------------
# 
# Package       : numpy
# Version       : v2.4.0
# Source repo   : https://github.com/numpy/numpy
# Tested on     : UBI:9.7
# Language      : Python
# Ci-Check      : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Viddya <Viddya@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

# Variables
PACKAGE_NAME=numpy
PACKAGE_VERSION=${1:-v2.4.0}
PACKAGE_URL=https://github.com/numpy/numpy
PACKAGE_DIR=numpy
PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/build-scripts/main/n/numpy/patch"

# Install dependencies
yum install -y python3 python3-pip python3-devel git cmake gcc gcc-c++ make

# Install Python dependencies
python3 -m pip install wheel meson meson-python ninja pytest

# Clone repository
git clone $PACKAGE_URL
cd $PACKAGE_DIR
git checkout $PACKAGE_VERSION

# Initialize submodules
git submodule update --init --recursive

# Apply patch for s390x GCD overflow fix (upstream PR #31360)
curl -s $PATCH_URL/numpy_v2.4.0.patch | git apply --ignore-whitespace -

# Install package
if ! python3 -m pip install . ; then
    echo "------------------$PACKAGE_NAME:Install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

# Run tests
cd /root
if ! (python3 -m pip install hypothesis && python3 -c "import numpy, sys; sys.exit(numpy.test() is False)"); then
    echo "------------------$PACKAGE_NAME:Install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:Install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
