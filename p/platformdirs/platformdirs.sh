#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : platformdirs
# Version       : 4.3.7
# Source repo   : https://github.com/tox-dev/platformdirs
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Aritrika Ghosh <aritrika@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - platformdirs is a pure-Python library
#   - Published noarch wheel installed via NOARCH, not rebuilt from source
#   - No compiled extensions; no extra system packages needed
#   - appdirs is required at test time by test_comp_with_appdirs.py, which
#     compares platformdirs output against the legacy appdirs package
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# PACKAGE_VERSION defaults to 4.3.7, overridable as $1
# =============================================================================
PACKAGE_NAME="platformdirs"
PACKAGE_VERSION="${1:-4.3.7}"
PACKAGE_URL="https://github.com/tox-dev/platformdirs/"

# =============================================================================
# OPTIONAL: Build configuration
# Pure-Python package; install directly from PyPI
# =============================================================================
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# No extra system packages needed; the container toolchain is sufficient
# =============================================================================
RH_DEP_PKGS=""

pre_test() {
    # test_comp_with_appdirs.py imports appdirs (the legacy predecessor to
    # platformdirs) to run a compatibility comparison; it must be installed
    # in the test venv before pytest collects tests.
    pip install appdirs
    # test_android.py, test_macos.py, and test_unix.py all use the mocker
    # fixture which is provided by pytest-mock; without it every parametrized
    # test in those files fails with "fixture 'mocker' not found".
    pip install pytest-mock
}

# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
