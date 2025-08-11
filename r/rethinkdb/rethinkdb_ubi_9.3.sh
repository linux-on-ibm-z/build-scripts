#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : rethinkdb
# Version        : v2.4.4
# Source repo    : https://github.com/rethinkdb/rethinkdb
# Tested on      : UBI: 9.3
# Language       : Ruby
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Nikhil Shinde <nikhil.shinde@ibm.com>
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
PACKAGE_NAME=rethinkdb
PACKAGE_VERSION=${1:-v2.4.4}
PACKAGE_URL=https://github.com/rethinkdb/rethinkdb

yum install -y sudo openssl-devel libcurl-devel wget tar unzip bzip2 m4 git-core gcc-c++ ncurses-devel which patch make ncurses zlib-devel zlib procps xz	

#build and install python2.7.18
wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tar.xz
tar -xvf Python-2.7.18.tar.xz
cd Python-2.7.18
./configure --prefix=/usr/local --exec-prefix=/usr/local
make
sudo make install
sudo ln -s /usr/bin/python2 /usr/bin/python
python -V
cd ..

yum install -y yum-utils

yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/AppStream/s390x/os/
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/AppStream/s390x/os/
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/BaseOS/s390x/os/

wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official
mv RPM-GPG-KEY-CentOS-Official /etc/pki/rpm-gpg/.
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official

#Install ruby
git clone -b $PACKAGE_VERSION $PACKAGE_URL
cd $PACKAGE_NAME
./configure --allow-fetch --fetch protoc
make -j4

if ! sudo make install; then
    echo "------------------$PACKAGE_NAME: install_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

if ! rethinkdb --bind all; then
    echo "------------------$PACKAGE_NAME:  install_success_server_is_up---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
fi
make -j4 DEBUG=1
if ! ./build/debug/rethinkdb-unittest; then
    echo "------------------$PACKAGE_NAME: build fails---------------------"
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
