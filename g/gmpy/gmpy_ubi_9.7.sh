#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package          : gmpy
# Version          : v2.2.1
# Source repo      : https://github.com/aleaxit/gmpy
# Tested on        : UBI 9.7
# Language         : Python
# Ci-Check         : True
# Script License   : Apache License, Version 2 or later
# Maintainer       : Sai Sindhuri Avulamanda <Sai.Sindhuri.Avulamanda@ibm.com>
#
# Disclaimer       : This script has been tested in root mode on given
# ==========         platform using the mentioned version of the package.
#                    It may not work as expected with newer versions of the
#                    package and/or distribution. In such case, please
#                    contact "Maintainer" of this script.
#
# -----------------------------------------------------------------------------

# Variables
PACKAGE_NAME=gmpy
PACKAGE_VERSION=${1:-v2.2.1}
PACKAGE_URL=https://github.com/aleaxit/gmpy
CURRENT_DIR=${PWD}

# Install dependencies and tools
yum install -y python3 python3-devel python3-pip git gcc gcc-c++ make gmp-devel mpfr-devel libmpc-devel

# Clone the source repository
cd $CURRENT_DIR
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

# Install
if ! python3 -m pip install . ; then
    echo "------------------$PACKAGE_NAME:Install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

# Install test dependencies
python3 -m pip install psutil pytest hypothesis

# Test
if ! pytest test/ ; then
    echo "------------------$PACKAGE_NAME:Install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:Install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
