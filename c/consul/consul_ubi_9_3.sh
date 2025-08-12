#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : consul
# Version        : v1.21.2
# Source repo    : https://github.com/hashicorp/consul.git
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
PACKAGE_NAME=consul
PACKAGE_VERSION=${1:-v1.21.2}
PACKAGE_URL=https://github.com/hashicorp/consul.git

# Install dependencies
yum install -y sudo gcc git make wget diffutils procps-ng tar python3 python3-pip
sudo ln -sf /usr/bin/gcc /usr/bin/s390x-linux-gnu-gcc

OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

# Install Go
GO_VERSION="1.23.8"
wget https://golang.org/dl/go${GO_VERSION}.linux-s390x.tar.gz
sudo tar -C /usr/local -xvzf go${GO_VERSION}.linux-s390x.tar.gz

# Clone the repository
git clone -b $PACKAGE_VERSION $PACKAGE_URL
cd $PACKAGE_NAME

if ! make tools; then
    echo "------------------$PACKAGE_NAME: build fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Build_Fails"
    exit 1
fi

if ! make dev; then
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
	echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
