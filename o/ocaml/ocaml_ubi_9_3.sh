#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : ocaml
# Version        : 5.3.0
# Source repo    : https://github.com/ocaml/ocaml.git
# Language       : ocaml
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Vishwajeet Rajopadhye <vishwajeet.rajopadhye@ibm.com>
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
PACKAGE_NAME=ocaml
PACKAGE_VERSION=${1:-5.3.0}
PACKAGE_URL=https://github.com/ocaml/ocaml.git

yum install -y gcc gcc-c++ make git gawk sed diffutils binutils hostname tar unzip cmake wget vim patch tcl gettext autoconf libtool automake bzip2 zlib zlib-devel


yum install -y yum-utils

yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/AppStream/s390x/os/
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/AppStream/s390x/os/
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/BaseOS/s390x/os/

wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official
mv RPM-GPG-KEY-CentOS-Official /etc/pki/rpm-gpg/.
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official

yum install bison -y

#Install ruby
git clone -b $PACKAGE_VERSION $PACKAGE_URL
cd $PACKAGE_NAME
./configure --enable-ocamltest

if ! make; then
    echo "------------------$PACKAGE_NAME: build_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

if ! make tests; then
    echo "------------------$PACKAGE_NAME:  build_success_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
fi
if ! make install; then
    echo "------------------$PACKAGE_NAME: test_passes_installation_fails---------------------"
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
