#!/bin/bash -e
# ----------------------------------------------------------------------------
#
# Package           : pandas
# Version           : 2.2.3
# Source repo       : https://github.com/pandas-dev/pandas
# Tested on         : UBI:9.6
# Language          : Python
# Ci-Check          : True
# Script License    : Apache License, Version 2 or later
# Maintainer        : Pranjal
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

set -e -o pipefail

PACKAGE_NAME="pandas"
PACKAGE_VERSION="2.2.3"
CURDIR="$(pwd)"
REPO_URL="https://github.com/pandas-dev/pandas"

LOG_FILE="$CURDIR/logs/${PACKAGE_NAME}-${PACKAGE_VERSION}-$(date +"%F-%T").log"
NON_ROOT_USER="$(whoami)"
FORCE="false"
TESTS="false"

trap cleanup 0 1 2 ERR

#Check if directory exists
if [ ! -d "$CURDIR/logs/" ]; then
    mkdir -p "$CURDIR/logs/"
fi

# Source OS release information
if [ -f "/etc/os-release" ]; then
    source "/etc/os-release"
else
    printf -- "Error: /etc/os-release file not found\n" |& tee -a "$LOG_FILE"
    exit 1
fi

function prepare() {
    if command -v "sudo" >/dev/null; then
        printf -- 'Sudo : Yes\n' >>"$LOG_FILE"
    else
        printf -- 'Sudo : No \n' >>"$LOG_FILE"
        printf -- 'You can install sudo from repository using apt, yum or zypper based on your distro. \n'
        exit 1
    fi

    if [[ "$FORCE" == "true" ]]; then
        printf -- 'Force attribute provided hence continuing with install without confirmation message\n' |& tee -a "$LOG_FILE"
    else
        printf -- 'As part of the installation, dependencies would be installed/upgraded.\n'
        while true; do
            read -r -p "Do you want to continue (y/n) ? :  " yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]*) exit ;;
            *) echo "Please provide Correct input to proceed." ;;
            esac
        done
    fi
}

function cleanup() {
    printf -- '\nCleaned up the artifacts\n' >>"$LOG_FILE"
}

function configureAndInstall() {
    printf -- '\nConfiguration and Installation started \n'

    printf -- 'User responded with Yes. \n'

    cd "${CURDIR}"

    # Download pandas source
    if [ ! -f "pyproject.toml" ]; then
        wget https://github.com/pandas-dev/pandas/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz
        tar -xvf v${PACKAGE_VERSION}.tar.gz
        cd pandas-${PACKAGE_VERSION}
    fi

    # Install generic deps
    pip3 install build wheel setuptools ninja numpy pytest pytest-xdist "versioneer[toml]"

    # Install pandas build deps
    pip3 install "Cython~=3.0.5" "meson==1.2.1" "meson-python==0.13.1" "patchelf>=0.11.0"

    # Build and install package
    printf -- 'Building ${PACKAGE_NAME} \n'

    python3 -m build . --wheel --no-isolation
    pip3 install dist/*.whl

    printf -- 'Built ${PACKAGE_NAME} successfully \n\n'
}

function runTest() {
    printf -- 'Running tests \n'

    cd "${CURDIR}"

    set +e

    python3 -c "import pandas; print(pandas.__version__)"

    pytest --pyargs pandas |& tee -a "$LOG_FILE"

    set -e
}


function logDetails() {
    printf -- 'SYSTEM DETAILS\n' >"$LOG_FILE"
    if [ -f "/etc/os-release" ]; then
        cat "/etc/os-release" >>"$LOG_FILE"
    fi

    cat /proc/version >>"$LOG_FILE"
    printf -- "\nDetected %s \n" "$PRETTY_NAME"
    printf -- "Request details : PACKAGE NAME= %s , VERSION= %s \n" "$PACKAGE_NAME" "$PACKAGE_VERSION" |& tee -a "$LOG_FILE"
}

function printHelp() {
    echo
    echo "Usage: "
    echo "  install.sh  [-d debug] [-y install-without-confirmation] [-t install-with-tests]"
    echo
}

while getopts "h?dyt" opt; do
    case "$opt" in
    h | \?)
        printHelp
        exit 0
        ;;
    d)
        set -x
        ;;
    y)
        FORCE="true"
        ;;
    t)
        TESTS="true"
        ;;
    esac
done

function printSummary() {
    printf -- '\n********************************************************************************************************\n'
    printf -- "\n* Getting Started * \n"
    printf -- '\nPackage ${PACKAGE_NAME} version ${PACKAGE_VERSION} installed successfully.'
    printf -- '\n\nFor more information visit https://github.com/pandas-dev/pandas \n\n'
    printf -- '**********************************************************************************************************\n'
}

logDetails
prepare

DISTRO="$ID-$VERSION_ID"

case "$DISTRO" in

"ubuntu-22.04" | "ubuntu-24.04" | "ubuntu-25.10")
    printf -- "Installing %s %s for %s \n" "$PACKAGE_NAME" "$PACKAGE_VERSION" "$DISTRO" |& tee -a "$LOG_FILE"
    printf -- "Installing dependencies... it may take some time.\n"

    sudo apt-get update

    sudo apt-get install -y \
        git cmake build-essential \
        python3 python3-pip python3-venv python3-dev \
        |& tee -a "$LOG_FILE"

    configureAndInstall |& tee -a "$LOG_FILE"
    ;;

"rhel-8.10" | "rhel-9.4" | "rhel-9.6" | "rhel-9.7" | "rhel-10.0" | "rhel-10.1")
    printf -- "Installing %s %s for %s \n" "$PACKAGE_NAME" "$PACKAGE_VERSION" "$DISTRO" |& tee -a "$LOG_FILE"
    printf -- "Installing dependencies... it may take some time.\n"

    sudo yum install -y \
        git cmake gcc gcc-c++ make \
        python3 python3-pip python3-devel \
        |& tee -a "$LOG_FILE"

    configureAndInstall |& tee -a "$LOG_FILE"
    ;;

"sles-15.7" | "sles-16.0")
    printf -- "Installing %s %s for %s \n" "$PACKAGE_NAME" "$PACKAGE_VERSION" "$DISTRO" |& tee -a "$LOG_FILE"
    printf -- "Installing dependencies... it may take some time.\n"

    sudo zypper install -y \
        git cmake gcc gcc-c++ make \
        python3 python3-pip python3-devel \
        |& tee -a "$LOG_FILE"

    configureAndInstall |& tee -a "$LOG_FILE"
    ;;

*)
    printf -- "%s not supported \n" "$DISTRO" |& tee -a "$LOG_FILE"
    exit 1
    ;;
esac

# Run tests
if [[ "$TESTS" == "true" ]]; then
    runTest |& tee -a "$LOG_FILE"
fi

cleanup
printSummary |& tee -a "$LOG_FILE"

