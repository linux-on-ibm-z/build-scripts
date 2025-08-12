#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : influxdb
# Version        : 2.7.11
# Source repo    : https://github.com/influxdata/influxdb
# Tested on      : UBI: 9.3
# Language       : rust
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Yugesh Nagvekar <Yugesh.Nagvekar@ibm.com>
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
PACKAGE_NAME=influxdb
PACKAGE_VERSION=${1:-v2.7.11}
BZR_VERSION=2.7.0
PACKAGE_URL=https://github.com/influxdata/influxdb
SCRIPT_DIR=$(pwd)
GO_VERSION=1.22.10
export GOPATH=$SCRIPT_DIR

# Install dependencies
yum install -y wget yum-utils

dnf config-manager --add-repo https://mirror.stream.centos.org/9-stream/CRB/s390x/os/
dnf config-manager --add-repo https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/
dnf config-manager --add-repo https://mirror.stream.centos.org/9-stream/BaseOS/s390x/os/
wget http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-Official
mv RPM-GPG-KEY-CentOS-Official /etc/pki/rpm-gpg/.
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official
yum install -y --allowerasing clang git gcc gcc-c++ wget protobuf protobuf-devel tar curl patch pkg-config make nodejs python3 gawk
ln -sf /usr/bin/python3 /usr/bin/python

OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

#install Bazaar
cd $SCRIPT_DIR
BZR_MAJOR_MINOR=$(echo "$BZR_VERSION" | awk -F'.' '{print $1"."$2}')
wget https://launchpad.net/bzr/"${BZR_MAJOR_MINOR}"/"${BZR_VERSION}"/+download/bzr-"${BZR_VERSION}".tar.gz
tar zxf bzr-"${BZR_VERSION}".tar.gz
export PATH=$PATH:$HOME/bzr-"${BZR_VERSION}"

# Install yarn
cd $SCRIPT_DIR
curl -o- -L https://yarnpkg.com/install.sh | bash
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Install Rust
cd $SCRIPT_DIR
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# Install Go
cd $GOPATH
wget -q https://storage.googleapis.com/golang/go"${GO_VERSION}".linux-s390x.tar.gz
chmod ugo+r go"${GO_VERSION}".linux-s390x.tar.gz
rm -rf /usr/local/go /usr/bin/go
tar -C /usr/local -xzf go"${GO_VERSION}".linux-s390x.tar.gz
ln -sf /usr/local/go/bin/go /usr/bin/ 
ln -sf /usr/local/go/bin/gofmt /usr/bin/
echo "Extracted the tar in /usr/local and created symlink"

if [ go version | grep -q "$GO_VERSION" ]; then
	echo "Installed $GO_VERSION successfully"
else 
    echo "Error while installing Go"
fi
go version
export PATH=$PATH:$GOPATH/bin

# Install pkg-config
cd $SCRIPT_DIR
export GO111MODULE=on
go install github.com/influxdata/pkg-config@v0.2.13
which -a pkg-config

# Download and configure InfluxDB
cd $SCRIPT_DIR
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION
export NODE_OPTIONS=--max_old_space_size=4096
rustup toolchain install 1.68-s390x-unknown-linux-gnu
make
cp ./bin/linux/* /usr/bin

# Check if influxdb is available
if [ ! -x /usr/bin/influxd ]; then
    echo "------------------$PACKAGE_NAME:Installtion_failed-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Installtion_Fails"
    exit 1
else
    echo "$PACKAGE_NAME version $PACKAGE_VERSION installed successfully at /usr/local/bin/"
	echo "All relevant binaries are installed in /usr/bin. Be sure to set the PATH as follows:"
    echo "export PATH=/usr/local/go/bin:\$PATH"
    echo "More information can be found here: https://docs.influxdata.com/influxdb/v2.7/get-started"
fi

if ! make test ; then
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
