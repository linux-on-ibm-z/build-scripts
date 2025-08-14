#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : HAProxy
# Version        : 3.2.1
# Source repo    : https://github.com/haproxy/haproxy
# Tested on      : UBI: 9.3
# Language       : c
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Sudip Roy <sudip.roy2@ibm.com>
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
PACKAGE_NAME=haproxy
PACKAGE_VERSION=${1:-3.2.1}
SCRIPT_DIR=$(pwd)
PACKAGE_URL_DIR=3.2
PACKAGE_URL=https://www.haproxy.org/download/${PACKAGE_URL_DIR}/src/haproxy-${PACKAGE_VERSION}.tar.gz
OPENSSL_VERSION=openssl-1.1.1w
OPENSSL_URL=https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz


# Install dependencies
yum install -y gcc gcc-c++ gzip make tar wget xz zlib-devel pcre2 pcre2-devel systemd-devel compat-openssl11 openssl-devel diffutils perl 

OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

# Install OpneSSL
cd $SCRIPT_DIR
wget --no-check-certificate $OPENSSL_URL
tar -xzf ${OPENSSL_VERSION}.tar.gz
cd $OPENSSL_VERSION
./config --prefix=/usr --openssldir=/usr
make
make install

# Build and install lua 
cd $SCRIPT_DIR
wget --no-check-certificate https://www.lua.org/ftp/lua-5.4.0.tar.gz
tar zxf lua-5.4.0.tar.gz
cd lua-5.4.0
sed -i '61 i \\t$(CC) -shared -ldl -Wl,-soname,liblua$R.so -o liblua$R.so $? -lm $(MYLDFLAGS)\n' src/Makefile
make clean
make linux "MYCFLAGS=-fPIC" "R=5.4"
make install
cp /usr/local/bin/lua* /usr/bin/
cp src/liblua5.4.so /usr/lib64/ 
rm -f /usr/lib64/liblua.so   
ln -s /usr/lib64/liblua5.4.so /usr/lib64/liblua.so  

lua -v   

# Configure and install haproxy
cd $SCRIPT_DIR
wget $PACKAGE_URL
tar xzf haproxy-${PACKAGE_VERSION}.tar.gz
cd haproxy-${PACKAGE_VERSION}
make all TARGET=linux-glibc USE_ZLIB=1 USE_PCRE2=1 USE_PCRE2_JIT=1 USE_LUA=1 USE_OPENSSL=1 
make install
ln -sf /usr/local/sbin/haproxy /usr/sbin/

# Check if installation of haproxy was successfully done

if [ ! -x /usr/local/sbin/haproxy ]; then
    echo "------------------$PACKAGE_NAME:Installtion failed.-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails"
    exit 1
else
    echo "$PACKAGE_NAME version $PACKAGE_VERSION installed successfully at /usr/local/bin/"
fi

# Run tests 
cd $SCRIPT_DIR
yum install -y --allowerasing socat curl python3
cd haproxy-${PACKAGE_VERSION}
scripts/build-vtest.sh
make -C addons/wurfl/dummy
make -j$(nproc) all \
    ERR=1 \
    TARGET=linux-glibc \
    CC=gcc \
    DEBUG="-DDEBUG_STRICT -DDEBUG_MEMORY_POOLS -DDEBUG_POOL_INTEGRITY" \
    USE_ZLIB=1 USE_PCRE2=1 USE_PCRE2_JIT=1 USE_LUA=1 USE_OPENSSL=1 USE_WURFL=1 WURFL_INC=addons/wurfl/dummy WURFL_LIB=addons/wurfl/dummy USE_DEVICEATLAS=1 DEVICEATLAS_SRC=addons/deviceatlas/dummy USE_PROMEX=1 USE_51DEGREES=1 51DEGREES_SRC=addons/51degrees/dummy/pattern \
    ADDLIB="-Wl,-rpath,/usr/local/lib/ -Wl,-rpath,$HOME/opt/lib/"
make install
if ! make reg-tests VTEST_PROGRAM=../vtest/vtest REGTESTS_TYPES=default,bug,devel ; then
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
