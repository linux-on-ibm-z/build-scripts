#!/bin/bash -e
# ----------------------------------------------------------------------------
#
# Package           : pandas
# Version           : 2.2.3
# Source repo       : https://github.com/pandas-dev/pandas
# Tested on         : UBI:9.6
# Language          : Python
# Ci-Check          : True
# Script License    : Apache License, Version 2 or later
# Maintainer        : Pranjal
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=pandas
PACKAGE_VERSION=2.2.3
PACKAGE_URL=https://github.com/pandas-dev/pandas

yum install -y \
    git \
    cmake \
    gcc \
    gcc-c++ \
    make \
    python3 \
    python3-pip \
    python3-devel \
    wget

git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout v$PACKAGE_VERSION

pip3 install --upgrade pip setuptools wheel build

pip3 install \
    ninja \
    numpy \
    pytest \
    pytest-xdist \
    hypothesis \
    "versioneer[toml]" \
    "Cython~=3.0.5" \
    "meson==1.2.1" \
    "meson-python==0.13.1" \
    "patchelf>=0.11.0"

if ! (python3 -m build . --wheel --no-isolation); then
    echo "------------------$PACKAGE_NAME:Build_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME | $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail | Build_Fails"
    exit 1
fi

WHEEL_FILE=$(find dist -name "*.whl" | head -1)

if ! (pip3 install "$WHEEL_FILE"); then
    echo "------------------$PACKAGE_NAME:Install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME | $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail | Install_Fails"
    exit 1
fi

echo "------------------$PACKAGE_NAME:Install_success-------------------------"
echo "$PACKAGE_URL $PACKAGE_NAME"
echo "$PACKAGE_NAME | $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Pass | Install_Success"

python3 -c "import pandas; print(pandas.__version__)"

if ! (pytest --pyargs pandas); then
    echo "------------------$PACKAGE_NAME:Install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME | $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail | Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:Install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME | $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Pass | Both_Install_and_Test_Success"
    exit 0
fi
