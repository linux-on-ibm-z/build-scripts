#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : Python
# Version        : 3.13.5
# Source repo    : https://github.com/python/cpython
# Tested on      : UBI: 9.3
# Language       : python
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Yash Ratawa <Yash.Ratawa@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

set -ex

# Variables
PACKAGE_NAME=python
PACKAGE_VERSION=${1:-3.13.5}
SCRIPT_DIR=$(pwd)
PACKAGE_URL=https://www.python.org/ftp/${PACKAGE_NAME}/${PACKAGE_VERSION}/Python-${PACKAGE_VERSION}.tgz

# Install dependencies
yum install -y bzip2-devel gcc gcc-c++ libffi-devel libuuid-devel make ncurses-devel openssl-devel tar tk-devel wget xz zlib-devel diffutils xz-devel patch
OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

# Install gdbm-devel
cd $SCRIPT_DIR
wget https://ftp.gnu.org/gnu/gdbm/gdbm-1.23.tar.gz
tar -xvf gdbm-1.23.tar.gz
cd gdbm-1.23
./configure --prefix=/usr/local --enable-libgdbm-compat
make
make install

# Configure and install haproxy
cd $SCRIPT_DIR
wget $PACKAGE_URL
tar -xzf Python-${PACKAGE_VERSION}.tgz
cd Python-${PACKAGE_VERSION}
./configure
make
make install

if [ ! -x /usr/local/bin/python3 ]; then
    echo "------------------$PACKAGE_NAME:Installtion failed.-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails"
    exit 1
else
    echo "$PACKAGE_NAME version $PACKAGE_VERSION installed successfully at /usr/local/bin/"
fi

# Run tests 
cd $SCRIPT_DIR
cd Python-${PACKAGE_VERSION}
if ! make test ; then
        echo "------------------$PACKAGE_NAME:install_success_but_test_fails---------------------"
        echo "$PACKAGE_URL $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Install_success_but_test_Fails"
        exit 2
else
        echo "------------------$PACKAGE_NAME:install_and_test_success-------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Install_and_Test_Success"
        exit 0
fi
