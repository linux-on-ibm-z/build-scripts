#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : doxygen
# Version        : 1.14.0 
# Source repo    : https://github.com/doxygen/doxygen
# Tested on      : UBI: 9.3
# Language       : c++
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Nikhil Shinde <Nikhil.Shinde7@ibm.com>
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
PACKAGE_NAME=doxygen
PACKAGE_VERSION=${1:-1.14.0}  
GITHUB_PACKAGE_VERSION=1_14_0
PACKAGE_URL=https://github.com/doxygen/doxygen

# Install dependencies
yum install -y git cmake wget unzip gcc gcc-c++ python3 make  diffutils openssl-devel 
yum install -y yum-utils
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/AppStream/s390x/os/
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/BaseOS/s390x/os/
wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official
mv RPM-GPG-KEY-CentOS-Official /etc/pki/rpm-gpg/.
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official
yum install -y bison flex texlive qt5-qtbase-devel texlive


OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout Release_$GITHUB_PACKAGE_VERSION
mkdir build
cd build
cmake -G "Unix Makefiles" -Dbuild_doc=ON -Dbuild_wizard=YES ..
make
wget https://github.com/doxygen/doxygen/releases/download/Release_${GITHUB_PACKAGE_VERSION}/doxygen_manual-${PACKAGE_VERSION}.pdf.zip
unzip doxygen_manual-${PACKAGE_VERSION}.pdf.zip
mkdir -p latex
mv doxygen_manual-${PACKAGE_VERSION}.pdf latex/doxygen_manual.pdf
make install
echo "Installation of doxygen completed"

# Check if doxygen is available
if [ ! -x /usr/local/bin/doxygen ]; then
    echo "------------------$PACKAGE_NAME:build_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails"
    exit 1
else
    echo "$PACKAGE_NAME version $PACKAGE_VERSION installed successfully at /usr/local/bin/"
fi


if ! make tests ; then
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
