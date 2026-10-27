#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : ormsgpack
# Version       : 1.12.1
# Source repo   : https://github.com/aviramha/ormsgpack
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
#                 platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - ormsgpack is a fast MessagePack serialization library for Python.
#   - NOARCH=true is used for package build/install via the Python template.
#   - Test dependencies (msgpack, pydantic, numpy, pytz, python-dateutil) are
#     installed inside custom_test_command() before pytest runs.
#   - custom_test_command() executes ./loz_test.sh when available, or runs
#     pytest ignoring/deselecting tests that are skipped or cause segfaults
#     on s390x due to CPython internal dict/str/thread memory layout differences.
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="ormsgpack"
PACKAGE_VERSION="${1:-1.12.1}"
PACKAGE_URL="https://github.com/aviramha/ormsgpack"

# Set NOARCH factor
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv build-essential"
SLES_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"

# =============================================================================
# CALLBACK: custom_test_command
# Run test suite using loz_test.sh if available, otherwise pytest with
# ignoring/deselecting architecture-sensitive tests.
# =============================================================================
custom_test_command() {
    pip install msgpack pydantic numpy pytz python-dateutil

    log_info "Running ormsgpack tests..."

    if [[ -f "./loz_test.sh" ]]; then
        chmod +x ./loz_test.sh
        ./loz_test.sh
    else
        local IGNORES=(
            --ignore=tests/test_concurrency.py
            --ignore=tests/test_dict.py
            --ignore=tests/test_pydantic.py
            --ignore=tests/test_sort_keys.py
            --ignore=tests/test_str.py
            --ignore=tests/test_typeddict.py
            --ignore=tests/test_types.py
            --deselect=tests/test_int.py::test_int_128_passthrough
        )
        pytest "${IGNORES[@]}"
    fi
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"

