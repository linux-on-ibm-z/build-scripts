#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : htop
# Version        : 3.4.1 
# Source repo    : https://github.com/htop-dev/htop
# Tested on      : UBI: 9.3
# Language       : c
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Yugesh Nagvekar <Yugesh.Nagvekar@ibm.com>
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
PACKAGE_NAME=htop
PACKAGE_VERSION=${1:-3.4.1}
PACKAGE_URL=https://github.com/htop-dev/htop

# Install dependencies
yum install -y ncurses-devel automake autoconf gcc git make 

OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION
./autogen.sh
./configure
make 
make install

# Check if htop is available
if [ ! -x /usr/local/bin/htop ]; then
    echo "------------------$PACKAGE_NAME:Installation_Fails------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Installation_Fails"
    exit 1
else
    echo "$PACKAGE_NAME version $PACKAGE_VERSION installed successfully at /usr/local/bin"
fi
