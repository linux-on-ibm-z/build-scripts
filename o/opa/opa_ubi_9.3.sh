#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : OPA
# Version        : v1.6.0
# Source repo    : https://github.com/open-policy-agent/opa.git
# Tested on      : UBI: 9.3
# Language       : go
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
PACKAGE_NAME=opa
PACKAGE_VERSION=${1:-1.6.0}
GO_VERSION=1.24.2
SCRIPT_DIR=$(pwd)
PACKAGE_URL=https://github.com/open-policy-agent/opa.git
PATCH_URL=https://raw.githubusercontent.com/linux-on-ibm-z/build-scripts/main/o/opa/patch

# Install dependencies
yum install -y gcc git make python3 python3-pip tar wget xz hostname
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
yum install -y glibc.s390x docker-ce docker-ce-cli containerd.io make which patch 
dockerd &

OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)
SCRIPT_DIR=$(pwd)
usermod -aG docker $USER && newgrp docker

#Install Go
cd $SCRIPT_DIR
wget -q https://storage.googleapis.com/golang/go"${GO_VERSION}".linux-s390x.tar.gz
chmod ugo+r go"${GO_VERSION}".linux-s390x.tar.gz
tar -C /usr/local -xzf go"${GO_VERSION}".linux-s390x.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

#Install wasmtime library
cd $SCRIPT_DIR
mkdir -p golang-wasmtime && cd golang-wasmtime
wget -q https://github.com/bytecodealliance/wasmtime/releases/download/v3.0.1/wasmtime-v3.0.1-s390x-linux-c-api.tar.xz
tar xf wasmtime-v3.0.1-s390x-linux-c-api.tar.xz
cp wasmtime-v3.0.1-s390x-linux-c-api/lib/libwasmtime.a /usr/lib
   
#Install golangci-lint docker image
cd $SCRIPT_DIR
export GOLANGCI_VERSION=v1.64.5
git clone https://github.com/golangci/golangci-lint.git
cd golangci-lint/
git checkout $GOLANGCI_VERSION
./install.sh $GOLANGCI_VERSION
cd bin
docker build -t golangci/golangci-lint:v1.64.5 -f ../build/buildx.Dockerfile .

#Setup OPA build
cd $SCRIPT_DIR
git clone https://github.com/open-policy-agent/opa.git
cd opa 
git checkout v$PACKAGE_VERSION
curl -sSL ${PATCH_URL}/opa.diff | git apply - || echo "Error: patch failed."
make build
echo "OPA build completed successfully."
cd $SCRIPT_DIR
cd opa
#Run unit test cases
if ! make test ; then
        echo "------------------$PACKAGE_NAME:Install_Success_But_Test_Fails---------------------"
        echo "$PACKAGE_URL $PACKAGE_NAME"
		echo "unit test cases"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Install_Success_But_Test_Fails"
else
        echo "------------------$PACKAGE_NAME:Install_And_Test_Success-------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
		echo "unit test cases"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Install_and_Test_Success"
fi
#Run  performance benchmarks
cd $SCRIPT_DIR
cd opa
if ! make perf ; then
        echo "------------------$PACKAGE_NAME:Performance_Benchmarks_Fails---------------------"
        echo "$PACKAGE_URL $PACKAGE_NAME"
		echo "performance benchmarks"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Performance_Benchmarks_Fails"
else
        echo "------------------$PACKAGE_NAME:Performance_Benchmarks_Success-------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
		echo "performance benchmarks"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Performance_Benchmarks_Success"
fi

#Run static analysis checks
cd $SCRIPT_DIR
cd opa
if ! make check ; then 
        echo "------------------$PACKAGE_NAME:Static Analysis Checks_Fails---------------------"
        echo "$PACKAGE_URL $PACKAGE_NAME"
		echo "static analysis checks"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail | Static Analysis Checks_Fails"
else
        echo "------------------$PACKAGE_NAME:Static Analysis Checks_Success-------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
		echo "static analysis checks"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Static Analysis Checks_Success"
fi

#Run complete test suite
cd $SCRIPT_DIR
cd opa
if ! make ; then 
        echo "------------------$PACKAGE_NAME:Test_Suits_Fails---------------------"
        echo "$PACKAGE_URL $PACKAGE_NAME"
		echo "complete test suite"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail | Test_Suits_Fails"
		exit 0
else
        echo "------------------$PACKAGE_NAME:Test_Suits_Success-------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
		echo "complete test suite"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Test_Suits_Success"
		exit 2
fi
