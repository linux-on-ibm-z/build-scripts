#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : multidict
# Version       : v6.3.2
# Source repo   : https://github.com/aio-libs/multidict
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License 2.0
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
#                 platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - Multidict contains native C extension code; built as a wheel.
#   - pytest-codspeed and pytest-cov are installed by pre_test() because
#     hypothesis requires a compatible environment at collection time.
#   - test_multidict_benchmarks.py and test_views_benchmarks.py import
#     pytest_codspeed at module level. custom_test_command() ignores them so
#     pytest collection does not fail when pytest-codspeed is absent at runtime.
#   - objgraph is required by tests under tests/isolated/.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="multidict"
PACKAGE_VERSION="${1:-v6.3.2}"
PACKAGE_URL="https://github.com/aio-libs/multidict"

NOARCH="false"

RH_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv build-essential"
SLES_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"

pre_build() {
    pip install --upgrade pip setuptools wheel build
}

pre_test() {
    pip install pytest-codspeed pytest-cov hypothesis betamax objgraph
}

custom_test_command() {
    # -p no:cov: pytest.ini has --cov in addopts; the coverage C tracer is
    # unavailable on s390x so pytest-cov crashes at startup. Disable it.
    # --ignore: the two benchmark files import pytest_codspeed at module level
    # which is still installed here but would break if ever removed.
    pytest -p no:cov \
        --ignore=tests/test_multidict_benchmarks.py \
        --ignore=tests/test_views_benchmarks.py
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
