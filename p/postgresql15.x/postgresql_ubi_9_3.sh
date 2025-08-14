#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : postgresql
# Version        : 15.13
# Source repo    : https://github.com/postgres/postgres
# Tested on      : UBI: 9.3
# Language       : C
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Yash Ratawa <yash.ratawa@ibm.com>
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
PACKAGE_NAME=postgresql
PACKAGE_VERSION=${1:-15.13}
PACKAGE_URL=https://ftp.postgresql.org/pub/source/v$PACKAGE_VERSION/$PACKAGE_NAME-$PACKAGE_VERSION.tar.gz

yum install -y sudo git wget gcc gcc-c++ tar make zlib-devel glibc-langpack-en procps-ng diffutils patch libicu-devel perl-FindBin perl-File-Compare

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
cd $PACKAGE_NAME-$PACKAGE_VERSION

if ! ./configure --without-icu ; then
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

if ! make install; then
    echo "------------------$PACKAGE_NAME: install_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1

else
    echo "------------------$PACKAGE_NAME:install_&_verification_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
