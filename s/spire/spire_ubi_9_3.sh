#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : spire
# Version        : v1.12.4
# Source repo    : https://github.com/spiffe/spire.git
# Tested on      : UBI: 9.3
# Language       : Go
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Sonal Deshmukh <sonal.deshmukh1@ibm.com>
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
PACKAGE_NAME=spire
PACKAGE_VERSION=${1:-v1.12.4}
PACKAGE_URL=https://github.com/spiffe/spire.git
export PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/build-scripts/main/s/spire/patch"

yum install -y sudo wget git make gcc openssl-devel

#Install spire
git clone -b$PACKAGE_VERSION $PACKAGE_URL
cd $PACKAGE_NAME
curl -sSL $PATCH_URL/spire.patch | git apply - 


if ! make; then
    echo "------------------$PACKAGE_NAME: build fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Build_Fails"
    exit 1
fi

if ! make test; then
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
