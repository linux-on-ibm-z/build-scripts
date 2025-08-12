#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : statsd
# Version        : v0.10.2
# Source repo    : https://github.com/etsy/statsd.git
# Tested on      : UBI: 9.3
# Language       : JavaScript
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Sankalp <sankalp@ibm.com>
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
PACKAGE_NAME=statsd
PACKAGE_VERSION=${1:-v0.10.2}
PACKAGE_URL=https://github.com/etsy/statsd.git

# Install dependencies
yum install -y sudo git wget tar unzip hostname make gcc-c++ xz gzip python3 nmap procps
sudo ln -sf /usr/bin/gcc /usr/bin/s390x-linux-gnu-gcc

OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

# Install NodeJS
NODE_VERSION=v18.17.1
wget https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-s390x.tar.xz
chmod ugo+r node-${NODE_VERSION}-linux-s390x.tar.xz
sudo tar -C /usr/local -xf node-${NODE_VERSION}-linux-s390x.tar.xz
export PATH=$PATH:/usr/local/node-${NODE_VERSION}-linux-s390x/bin

#Install statsd
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

if ! npm install ; then
        echo "------------------$PACKAGE_NAME:build_fails-------------------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails"
        exit 1
fi

if ! ./run_tests.js ; then
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
