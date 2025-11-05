#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : Apache HTTP Server
# Version        : 2.4.65 
# Source repo    : https://github.com/apache/httpd
# Tested on      : UBI: 9.3
# Language       : c
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Vibhuti Sawant <vibhuti.sawant@ibm.com>
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
PACKAGE_NAME=apachehttpserver
APR_VERSION=1.7.6
APR_UTIL_VERSION=1.6.3
PACKAGE_VERSION=${1:-2.4.65}
SCRIPT_DIR=$(pwd)
PACKAGE_URL=https://github.com/apache/httpd

# Install dependencies
yum install -y git openssl openssl-devel python3 gcc libtool autoconf make pcre pcre-devel libxml2 libxml2-devel expat-devel diffutils file which procps wget tar 

OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

cd $SCRIPT_DIR
git clone $PACKAGE_URL
cd httpd
git checkout $PACKAGE_VERSION
cd srclib
git clone https://github.com/apache/apr.git
cd apr 
git checkout $APR_VERSION
cd $SCRIPT_DIR/httpd/srclib
git clone https://github.com/apache/apr-util.git
cd apr-util
git checkout $APR_UTIL_VERSION
cd $SCRIPT_DIR/httpd
./buildconf
./configure --with-included-apr --prefix=/usr/local
make
make install


# Check if httpd is available
if [ ! -x /usr/local/bin/httpd ]; then
    echo "------------------$PACKAGE_NAME:Installtion failed.-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails"
    exit 1
else
    echo "$PACKAGE_NAME version $PACKAGE_VERSION installed successfully at /usr/local/bin/"
fi
