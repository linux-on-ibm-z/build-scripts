#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package       : libidn2
# Version       : 2.3.2
# Source repo   : https://ftp.gnu.org/gnu/libidn
# Tested on     : UBI:9.7
# Language      : C, Python
# Ci-Check      : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Keerthana GR <Keerthana.G.R@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

# Variables
PACKAGE_NAME=libidn2
PACKAGE_VERSION=${1:-2.3.2}
PACKAGE_URL=https://ftp.gnu.org/gnu/libidn
PACKAGE_DIR=libidn2-${PACKAGE_VERSION}
CURRENT_DIR=${PWD}

# Install dependencies
yum install -y python3 python3-pip python3-devel git gcc gcc-c++ make autoconf automake libtool gettext-devel libunistring-devel wget gperf gengetopt

# Download and extract tarball (has pre-generated configure)
wget ${PACKAGE_URL}/libidn2-${PACKAGE_VERSION}.tar.gz
tar -xzf libidn2-${PACKAGE_VERSION}.tar.gz
cd $PACKAGE_DIR

mkdir prefix
export PREFIX=$(pwd)/prefix

export target_platform=$(uname)-$(uname -m)
export CC=$(which gcc)
export CXX=$(which g++)

# Configure (tarball has configure pre-generated)
./configure --prefix=$PREFIX \
    --enable-shared \
    --disable-static \
    --disable-doc

# Build and install
make -j$(nproc)
make install

# Create local directory structure for wheel
mkdir -p local/libidn2
touch local/__init__.py
cp -r prefix/* local/libidn2/

export LD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/lib64:${LD_LIBRARY_PATH}

# Download pyproject.toml file
wget https://raw.githubusercontent.com/linux-on-ibm-z/build-scripts/refs/heads/main/l/libidn2/pyproject.toml
sed -i s/{PACKAGE_VERSION}/$PACKAGE_VERSION/g pyproject.toml

# Run tests
if ! make check ; then
    echo "------------------$PACKAGE_NAME:Install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitLab | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:Install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitLab  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
