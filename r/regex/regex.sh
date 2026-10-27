#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : regex
# Version       : 2024.11.6
# Source repo   : https://github.com/mrabarnett/mrab-regex.git
# Tested on     : UBI:9.8
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Sai-Sindhuri-Avulamanda <Sai.Sindhuri.Avulamanda@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - Backwards-compatible re module replacement with additional functionality
#   - Ships a C extension (_regex); the wheel is architecture-specific
#   - No build-system.requires beyond what the template pre-installs (setuptools, build, wheel)
#   - C library with Python bindings
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="regex"
PACKAGE_VERSION="${1:-2024.11.6}"
PACKAGE_URL="https://github.com/mrabarnett/mrab-regex.git"

# REQUIRED: Dependencies
RH_DEP_PKGS=""

# CALLBACK: custom_test_command
#   test_main() in test_regex.py is unittest's own entry point (unittest.main()); pytest
# collects it as a test and it exits 5 (no tests) on any architecture. Run the suite
# with unittest against the installed package instead.
custom_test_command() {
    python -m unittest -v regex.test_regex
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
