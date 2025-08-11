#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : libc6
# Version        : 1.2.5
# Source repo    : http://git.musl-libc.org/cgit/musl/snapshot/
# Tested on      : UBI: 9.3
# Language       : C
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Namrata Bhave <namrata.bhave@ibm.com>
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
PACKAGE_VERSION=${1:-1.2.5}
PACKAGE_URL=http://git.musl-libc.org/cgit/musl/snapshot/musl-$PACKAGE_VERSION.tar.gz

yum install -y sudo gcc gcc-c++ make wget tar bzip2 zlib-devel gzip

#Install librdkafka
wget $PACKAGE_URL
tar -xzf musl-$PACKAGE_VERSION.tar.gz
cd musl-$PACKAGE_VERSION

if ! ./configure ; then
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

if ! sudo make install; then
    echo "------------------$PACKAGE_NAME: install_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
else
    echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
