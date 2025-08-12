#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : ruby
# Version        : v3.4.5
# Source repo    : http://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.5.tar.gz
# Tested on      : UBI: 9.3
# Language       : Ruby
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Yugesh Nagvekar <yugesh.nagvekar@ibm.com>
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
PACKAGE_NAME=ruby
PACKAGE_VERSION=${1:-3.4.5}
PACKAGE_URL=http://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.5.tar.gz

yum install -y sudo openssl-devel gcc make wget tar libyaml-devel gcc make glibc-devel autoconf automake libtool wget

#building gdvm-devel from source
wget https://ftp.gnu.org/gnu/gdbm/gdbm-1.23.tar.gz
tar -xzf gdbm-1.23.tar.gz
cd gdbm-1.23
./configure --prefix=/usr/local
make -j$(nproc)
sudo make install
cd ..

yum install -y yum-utils

yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/AppStream/s390x/os/
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/AppStream/s390x/os/
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/BaseOS/s390x/os/

wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official
mv RPM-GPG-KEY-CentOS-Official /etc/pki/rpm-gpg/.
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official

yum install -y bison flex readline-devel

#Install ruby
wget $PACKAGE_URL
tar zxf $PACKAGE_NAME-$PACKAGE_VERSION.tar.gz
cd ruby-$PACKAGE_VERSION

if ! ./configure ; then
    echo "------------------$PACKAGE_NAME: configuration fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Configuration_Fails"
    exit 1
fi

if ! make; then
    echo "------------------$PACKAGE_NAME: build fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Build_Fails"
    exit 1
fi

if ! sudo make install; then
    echo "------------------$PACKAGE_NAME: install_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

if ! ruby -v; then
    echo "------------------$PACKAGE_NAME:  install_success_but_verification_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:install_&_verification_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
