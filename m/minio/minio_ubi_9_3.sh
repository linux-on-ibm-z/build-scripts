#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : minio
# Version        : RELEASE.2025-07-16T15-35-03Z
# Source repo    : https://github.com/minio/minio.git
# Tested on      : UBI: 9.3
# Language       : go
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Firoj Patel <firoj.Patel@ibm.com>
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
PACKAGE_NAME=minio
PACKAGE_VERSION=${1:-RELEASE.2025-07-18T21-56-31Z}
PACKAGE_URL=https://github.com/minio/minio.git

# Install dependencies
yum install -y git make wget tar gcc which diffutils jq sudo
sudo ln -sf /usr/bin/gcc /usr/bin/s390x-linux-gnu-gcc

OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

# Install Go
GO_VERSION="1.24.2"
wget https://golang.org/dl/go${GO_VERSION}.linux-s390x.tar.gz
sudo tar -C /usr/local -xvzf go${GO_VERSION}.linux-s390x.tar.gz

# Clone the repository
git clone -b $PACKAGE_VERSION $PACKAGE_URL
go install mvdan.cc/gofumpt@latest
gofumpt -l -w .
cd $PACKAGE_NAME

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

if ! make test; then
    echo "------------------$PACKAGE_NAME:  install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    minio server data
	echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
