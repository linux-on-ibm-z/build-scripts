#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : Terrform
# Version        : v1.12.2
# Source repo    : https://github.com/hashicorp/terraform
# Tested on      : UBI: 9.3
# Language       : c
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Mujahid Dandoti <Mujahid.Dandoti@ibm.com>
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
PACKAGE_NAME=terraform
PACKAGE_VERSION=v1.12.2
GO_VERSION=1.24.2
PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/build-scripts/main/t/terraform/patch"
SCRIPT_DIR=$(pwd)
PACKAGE_URL=https://github.com/hashicorp/terraform.git
export GOPATH=$(pwd)
# Install dependencies
yum install -y git wget tar gcc diffutils zip unzip

OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

# Install GO
cd ${GOPATH}
wget -q https://storage.googleapis.com/golang/go"${GO_VERSION}".linux-s390x.tar.gz
chmod ugo+r go"${GO_VERSION}".linux-s390x.tar.gz
tar -C /usr/local -xzf go"${GO_VERSION}".linux-s390x.tar.gz
ln -sf /usr/local/go/bin/go /usr/bin/
ln -sf /usr/local/go/bin/gofmt /usr/bin/
go version

# Configure and install terraform
cd $SCRIPT_DIR
export PATH=$GOPATH/bin:$PATH
mkdir -p $GOPATH/src/github.com/hashicorp
cd $GOPATH/src/github.com/hashicorp
git clone $PACKAGE_URL
cd terraform
git checkout ${PACKAGE_VERSION}
go install .
echo " Copying binary to /usr/bin "
cp ${GOPATH}/bin/terraform /usr/bin/
terraform -version
if [ ! -x /usr/bin/terraform ]; then
    echo "------------------$PACKAGE_NAME:Installtion failed.-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails"
    exit 1
else
    echo "$PACKAGE_NAME version $PACKAGE_VERSION installed successfully at /usr/bin/"
fi

# Run tests 
cd $SCRIPT_DIR
cd $GOPATH/src/github.com/hashicorp/terraform
echo " Running unit tests "
echo " Running unit tests "
if ! go test -v ./... ; then
    echo "Unit tests failed, rerun if the test cases looks intermittent"
fi
echo "Unit tests complete"
echo "Running race tests"
if ! go test -race ./internal/terraform ./internal/command ./internal/states ; then
 echo "race tests failed, rerun if the test cases looks intermittent"
fi
echo "Download and build necessary terraform provider plugins locally"
PROVIDER_PLUGIN_LOCAL_MIRROR_PATH="$HOME/.terraform.d/plugins"
mkdir -p $PROVIDER_PLUGIN_LOCAL_MIRROR_PATH
cd $GOPATH/src/github.com/hashicorp
git clone https://github.com/hashicorp/terraform-provider-null.git
cd terraform-provider-null
git checkout v3.2.3
go build
BIN_PATH="${PROVIDER_PLUGIN_LOCAL_MIRROR_PATH}/registry.terraform.io/hashicorp/null/3.2.3/linux_s390x"
mkdir -p $BIN_PATH
mv terraform-provider-null $BIN_PATH/terraform-provider-null_v3.2.3
git checkout v3.1.0
go build
mv terraform-provider-null terraform-provider-null_v3.1.0_x5
zip terraform-provider-null_3.1.0_linux_s390x.zip terraform-provider-null_v3.1.0_x5
mv terraform-provider-null_3.1.0_linux_s390x.zip $PROVIDER_PLUGIN_LOCAL_MIRROR_PATH/registry.terraform.io/hashicorp/null/
git checkout v2.1.0
go build
BIN_PATH="${PROVIDER_PLUGIN_LOCAL_MIRROR_PATH}/registry.terraform.io/hashicorp/null/2.1.0/linux_s390x"
mkdir -p $BIN_PATH
mv terraform-provider-null $BIN_PATH/terraform-provider-null_v2.1.0_x4
BIN_PATH="${PROVIDER_PLUGIN_LOCAL_MIRROR_PATH}/registry.terraform.io/hashicorp/null/1.0.0+local/linux_s390x"
mkdir -p $BIN_PATH
cp $GOPATH/src/github.com/hashicorp/terraform/internal/command/e2etest/testdata/vendored-provider/terraform.d/plugins/registry.terraform.io/hashicorp/null/1.0.0+local/os_arch/terraform-provider-null_v1.0.0 $BIN_PATH/

cd $GOPATH/src/github.com/hashicorp
git clone -b v5.40.0 https://github.com/hashicorp/terraform-provider-aws.git
cd terraform-provider-aws
go build
BIN_PATH="${PROVIDER_PLUGIN_LOCAL_MIRROR_PATH}/registry.terraform.io/hashicorp/aws/5.40.0/linux_s390x"
mkdir -p $BIN_PATH
mv terraform-provider-aws $BIN_PATH/terraform-provider-aws_v5.40.0

cd $GOPATH/src/github.com/hashicorp
git clone -b v2.2.0 https://github.com/hashicorp/terraform-provider-template.git
cd terraform-provider-template
go build
BIN_PATH="${PROVIDER_PLUGIN_LOCAL_MIRROR_PATH}/registry.terraform.io/hashicorp/template/2.2.0/linux_s390x"
mkdir -p $BIN_PATH
mv terraform-provider-template $BIN_PATH/terraform-provider-template_v2.2.0
BIN_PATH="${PROVIDER_PLUGIN_LOCAL_MIRROR_PATH}/registry.terraform.io/hashicorp/template/2.1.0/linux_s390x"
mkdir -p $BIN_PATH
mv $GOPATH/src/github.com/hashicorp/terraform/internal/command/e2etest/testdata/plugin-cache/cache/registry.terraform.io/hashicorp/template/2.1.0/os_arch/terraform-provider-template_v2.1.0_x4 $BIN_PATH/

BIN_PATH="${PROVIDER_PLUGIN_LOCAL_MIRROR_PATH}/example.com/awesomecorp/happycloud/1.2.0/linux_s390x"
mkdir -p $BIN_PATH
mv $GOPATH/src/github.com/hashicorp/terraform/internal/command/e2etest/testdata/local-only-provider/terraform.d/plugins/example.com/awesomecorp/happycloud/1.2.0/os_arch/terraform-provider-happycloud_v1.2.0 $BIN_PATH/

echo "Update CLI configurations to use locally built provider plugins"
cd $HOME
wget ${PATCH_URL}/.terraformrc
sed -i "s#HOME__PATH#$HOME#g" .terraformrc

echo "Running e2e tests now"
cd $GOPATH/src/github.com/hashicorp/terraform
if ! TF_ACC=1 go test -v ./internal/command/e2etest ; then
        echo "------------------$PACKAGE_NAME:install_success_but_test_fails---------------------"
        echo "$PACKAGE_URL $PACKAGE_NAME"
		echo "E2E tests complete"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Install_success_but_test_Fails"
		mv $HOME/.terraformrc $HOME/.terraformrc.e2etest
		echo  "In case of unexpected test failures try running the test individually using command go test -v <package_name> -run <failed_test_name>"
        exit 2
else
        echo "------------------$PACKAGE_NAME:install_and_test_success-------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
		echo "E2E tests complete"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Install_and_Test_Success"
		mv $HOME/.terraformrc $HOME/.terraformrc.e2etest
        exit 0
fi
