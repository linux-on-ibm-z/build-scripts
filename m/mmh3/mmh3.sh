#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : mmh3
# Version       : v5.2.0
# Source repo   : https://github.com/hajimes/mmh3
# Tested on     : UBI:9.3
# Language      : Python
# Script License: BSD 3-Clause License
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
#                 platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - mmh3 is a Python extension for the MurmurHash3 algorithm.
#   - The package contains native C extension code and is therefore
#     architecture-specific.
#   - The build requires a compatible setuptools version because the
#     package uses tool.setuptools.ext-modules in pyproject.toml.
#   - The test suite requires uv, installed directly inside custom_test_command.
#   - The tests directory must be available on PYTHONPATH because some
#     test modules import helper utilities directly from that directory.
#   - Setuptools and GCC warnings observed during compilation are
#     non-blocking warnings and do not prevent the package from building.
# -----------------------------------------------------------------------------

# Get the directory containing this script.
# This allows the common Python template to be sourced reliably.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Package information.
PACKAGE_NAME="mmh3"
PACKAGE_VERSION="${1:-v5.2.0}"
PACKAGE_URL="https://github.com/hajimes/mmh3"

# mmh3 contains native C extension code, so it is architecture-specific.
NOARCH="false"

# System packages required to build the native C extension.
RH_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv build-essential"
SLES_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"

# Install build dependencies required by mmh3.
# A newer setuptools version is required to support the
# tool.setuptools.ext-modules configuration used by the package.
pre_build() {
    log_info "Installing build dependencies..."

    pip install --upgrade \
        pip \
        "setuptools>=74.1.0" \
        wheel \
        build
}

# Run the mmh3 test suite.
# uv (required by the upstream test configuration) is installed here directly.
# The tests directory is added to PYTHONPATH because some test modules import
# helper utilities directly from that directory.
custom_test_command() {
    log_info "Installing test dependencies..."
    pip install --upgrade uv

    log_info "Running mmh3 tests..."

    set -o pipefail

    PYTHONPATH="${PWD}/tests${PYTHONPATH:+:${PYTHONPATH}}" \
        pytest -v | tee test_output.txt
}

# Source the common Python build and test template.
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
