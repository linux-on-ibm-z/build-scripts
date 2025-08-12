#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : openresty
# Version        : v1.27.1.2
# Source repo    : https://github.com/openresty/openresty.git
# Tested on      : UBI: 9.3
# Language       : C
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Sangita Nalkar <sangita.nalkar@ibm.com>
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
PACKAGE_NAME=openresty
PACKAGE_VERSION=${1:-1.27.1.2}
PACKAGE_URL=https://github.com/openresty/openresty.git
INSTALL_URL=https://openresty.org/download/openresty-$PACKAGE_VERSION.tar.gz

yum install -y sudo openssl-devel tar wget make gcc dos2unix perl patch pcre-devel zlib-devel perl-App-cpanminus git	

#clone openresty
git clone -b v$PACKAGE_VERSION $PACKAGE_URL
cd $PACKAGE_NAME
export PCRE_VER=10.44
export PCRE_PREFIX=/opt/pcre2
export PCRE_LIB=$PCRE_PREFIX/lib
export PCRE_INC=$PCRE_PREFIX/include
wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE_VER}/pcre2-${PCRE_VER}.tar.gz
tar -xzf pcre2-$PCRE_VER.tar.gz
cd pcre2-$PCRE_VER/
./configure --prefix=$PCRE_PREFIX --enable-jit --enable-utf --enable-unicode-properties
make -j$JOBS
sudo PATH=$PATH make install
wget --no-check-certificate $INSTALL_URL
tar xvf openresty-$PACKAGE_VERSION.tar.gz
./configure 

if ! sudo make install; then
    echo "------------------$PACKAGE_NAME: install_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi
export PATH=/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin:$PATH
sudo cpanm --notest Test::Nginx IPC::Run3
if ! prove -I. -r t/; then
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
