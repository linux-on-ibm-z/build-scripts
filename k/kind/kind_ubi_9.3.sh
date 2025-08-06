#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : kind
# Version        : v0.29.0
# Source repo    : https://github.com/kubernetes-sigs/kind.git
# Tested on      : UBI: 9.3
# Language       : Go
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
PACKAGE_NAME=kind
PACKAGE_VERSION=${1:-v0.29.0}
PACKAGE_URL=https://github.com/kubernetes-sigs/kind.git
export PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/build-scripts/main/k/kind/patch"

yum install -y sudo docker git make wget tar gcc glibc.s390x make which patch

git clone -b $PACKAGE_VERSION $PACKAGE_URL
cd $PACKAGE_NAME
curl -s $PATCH_URL/kind.patch | git apply --ignore-whitespace -

if ! make build; then
    echo "------------------$PACKAGE_NAME: build_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi
export PATH=/kind/bin:$PATH
if ! make test; then
    echo "------------------$PACKAGE_NAME: build_passes_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Build_Fails"
    exit 1
fi
else
    echo "------------------$PACKAGE_NAME:install_&_verification_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
