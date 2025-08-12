#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : librdkafka
# Version        : v2.10.1
# Source repo    : https://github.com/confluentinc/librdkafka.git
# Tested on      : UBI: 9.3
# Language       : C
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Yash Ratawa <yash.ratawa@ibm.com>
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
PACKAGE_NAME=librdkafka
PACKAGE_VERSION=${1:-v2.10.1}
PACKAGE_URL=https://github.com/confluentinc/librdkafka.git

yum install -y sudo git openssl-devel cyrus-sasl-devel python3 gcc gcc-c++ zlib-devel binutils make wget

#Install librdkafka
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

if ! ./configure --install-deps ; then
    echo "------------------$PACKAGE_NAME: configuration fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Configuration_Fails"
    exit 1
fi

if ! make; then
    echo "------------------$PACKAGE_NAME: build fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Build_Fails"
    exit 1
fi

if ! make install; then
    echo "------------------$PACKAGE_NAME: install_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

if ! make -C tests run_local_quick; then
    echo "------------------$PACKAGE_NAME:  install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
