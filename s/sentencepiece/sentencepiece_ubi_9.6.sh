#!/bin/bash -e
# ----------------------------------------------------------------------------
#
# Package       : sentencepiece
# Version       : v0.2.1
# Source repo   : https://github.com/google/sentencepiece.git
# Tested on     : UBI:9.6
# Language      : Python, C++
# Ci-Check      : True
# Script License: Apache License, Version 2.0 or later
# Maintainer    : Purva Kale <purva.kale@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

# Variables
PACKAGE_NAME=sentencepiece
PACKAGE_VERSION=${1:-v0.2.1}
PACKAGE_URL=https://github.com/google/sentencepiece.git

# Install dependencies
yum install -y git cmake gcc gcc-c++ make pkg-config python3 python3-pip python3-devel

# Clone repository
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

# Build C++ library
mkdir -p build && cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DSPM_ENABLE_SHARED=ON
make -j"$(nproc)"
sudo make install
cd ..

# Build Python wheel
cd python
cp ../LICENSE .

pip3 install --upgrade pip setuptools wheel build

if ! (python3 -m build --wheel --no-isolation) ; then
    echo "------------------$PACKAGE_NAME:Build_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail | Build_Fails"
    exit 1
fi

# Install wheel
WHEEL_FILE=$(find dist -name "*.whl" | head -1)
if ! (pip3 install "$WHEEL_FILE") ; then
    echo "------------------$PACKAGE_NAME:Install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail | Install_Fails"
    exit 1
fi

echo "------------------$PACKAGE_NAME:Install_success-------------------------"
echo "$PACKAGE_URL $PACKAGE_NAME"
echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Pass | Install_Success"

# Test
# Note: python setup.py test is deprecated in setuptools>=61.0
# Using pytest instead
pip3 install pytest
if ! (pytest test/) ; then
    echo "------------------$PACKAGE_NAME:Install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail | Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:Install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Pass | Both_Install_and_Test_Success"
    exit 0
fi