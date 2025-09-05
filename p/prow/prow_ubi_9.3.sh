#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : prow
# Version        : master
# Source repo    : https://github.com/kubernetes/test-infra
# Tested on      : UBI: 9.3
# Language       : go
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Sangita Nalkar <Sangita.Nalkar@ibm.com>
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
PACKAGE_NAME=prow
PACKAGE_VERSION=master
GOLANG_VERSION=1.19.5
SCRIPT_DIR=$(pwd)
PACKAGE_URL=https://github.com/kubernetes/test-infra.git
PATCH_URL=https://raw.githubusercontent.com/linux-on-ibm-z/build-scripts/main/p/prow/patch

# Install dependencies
yum install -y zip tar unzip git vim wget make python3-devel gcc gcc-c++ libtool autoconf expat-devel openssl-devel zlib-devel perl-CPAN perl-devel rsync
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
yum install -y glibc.s390x docker-ce docker-ce-cli containerd.io make which patch
dockerd &
OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)
SCRIPT_DIR=$(pwd)
usermod -aG docker $USER && newgrp docker

# Install Go
cd $SCRIPT_DIR
wget https://golang.org/dl/go${GOLANG_VERSION}.linux-s390x.tar.gz
tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-s390x.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

# Ensure s390x-linux-gnu-gcc symlink exists
if ! command -v s390x-linux-gnu-gcc; then
    ln -s /usr/bin/gcc /usr/bin/s390x-linux-gnu-gcc
fi

# Build jq 
cd $SCRIPT_DIR
git clone https://github.com/stedolan/jq.git
cd jq
git checkout jq-1.5
autoreconf -fi
./configure --disable-valgrind
make -j$(nproc) LDFLAGS=-all-static
make install
jq --version

# Setup Prow build
cd $SCRIPT_DIR
git clone $PACKAGE_URL
cd test-infra
git checkout 89ac42333a8e7d3d88eda931740199b2a25252ea
curl -sSL ${PATCH_URL}/test-infra-patch.diff | git apply - || echo "Error: patch failed."

# Build prow images
if ! make -C prow build-images; then
    echo "------------------$PACKAGE_NAME:Build_Fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "build"
    echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail | Build_Fails"
    exit 1
else
    echo "------------------$PACKAGE_NAME:Build_Success-------------------------"
    echo "$PACKAGE_VERSION $PACKAGE_NAME"
    echo "build"
    echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass | Build_Success"
fi

# Run unit test cases
cd $SCRIPT_DIR
cat <<EOF >setenv.sh
export GOPATH=$GOPATH
export PATH=$PATH
export LOGDIR=$LOGDIR
EOF

cd $SCRIPT_DIR
cd test-infra/
mkdir _bin/jq-1.5
cp /usr/local/bin/jq _bin/jq-1.5/jq
cp /usr/local/bin/jq _bin/jq-1.5/jq-linux64
if ! make test; then
    echo "------------------$PACKAGE_NAME:Test_Fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Test_Fails"
else
    echo "------------------$PACKAGE_NAME:Install_And_Test_Success-------------------------"
    echo "$PACKAGE_VERSION $PACKAGE_NAME"
    echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass | Test_Success"
fi
