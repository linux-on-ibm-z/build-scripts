#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : XMLSec
# Version        : 1.3.7
# Source repo    : https://github.com/lsh123/xmlsec
# Tested on      : UBI: 9.3
# Language       : c
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
PACKAGE_NAME=xmlsec
LIBTOOL_VERSION=2.4.6
OPENSSL_VERSION=1.1.1 
PACKAGE_VERSION=${1:-xmlsec_1_3_7}

PACKAGE_URL=https://github.com/lsh123/xmlsec

# Install dependencies
yum install -y git gcc make autoconf automake libtool libxslt-devel diffutils tar wget perl-CPAN


OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)
SCRIPT_DIR=$(pwd)

# Build and install libltdl from libtool
cd $SCRIPT_DIR
wget http://ftp.gnu.org/gnu/libtool/libtool-${LIBTOOL_VERSION}.tar.gz
tar -xf libtool-${LIBTOOL_VERSION}.tar.gz
cd libtool-${LIBTOOL_VERSION}
./configure --enable-ltdl-install
make
make install

# Install OpenSSL
cd $SCRIPT_DIR
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}h.tar.gz --no-check-certificate
tar -xzvf openssl-1.1.1h.tar.gz
cd openssl-1.1.1h
./config --prefix=/usr/local --openssldir=/usr/local
make
make install 

cd $SCRIPT_DIR
export LDFLAGS="-L/usr/local/lib/ -L/usr/local/lib64/"
export LD_LIBRARY_PATH=/usr/local/lib/:/usr/local/lib64/:/usr/lib/:/usr/lib64/${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export CPPFLAGS="-I/usr/local/include/ -I/usr/local/include/openssl"
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION
./autogen.sh --without-gcrypt --with-openssl 
make 
make install

# Check if XMLsec is available
if [ ! -x /usr/local/bin/xmlsec1 ]; then
    echo "------------------$PACKAGE_NAME:Installation_Fails.-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Installation_Fails"
    exit 1
else
    echo "$PACKAGE_NAME version $PACKAGE_VERSION installed successfully at /usr/local/bin"
fi

if ! make check ; then
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
