#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : monotonic
# Version       : 1.5
# Source repo   : https://github.com/atdt/monotonic
# Tested on     : UBI:9.6
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Viddya K <viddya.k@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# PACKAGE_VERSION defaults to 1.5, overridable as $1
# =============================================================================
PACKAGE_NAME="monotonic"
PACKAGE_VERSION="${1:-1.5}"
PACKAGE_VERSION="${PACKAGE_VERSION#v}"
PYPI_VERSION="${PACKAGE_VERSION#v}"
PACKAGE_URL="https://github.com/atdt/monotonic"

# =============================================================================
# OPTIONAL: Build configuration
# Published release provides a platform-independent wheel — no rebuild needed.
# =============================================================================
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# monotonic is pure Python — only needs git + pip tooling
# =============================================================================
RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

# =============================================================================
# OPTIONAL: Custom test command
# This release has no upstream test suite. The inline script validates the
# installed public API from /tmp so that monotonic.py in the source tree
# cannot shadow the installed wheel.
# =============================================================================
custom_test_command() {
    (cd /tmp && python - <<'PYTEST'
import time
from monotonic import monotonic
values = [monotonic() for _ in range(1000)]
assert all(isinstance(value, float) for value in values)
assert all(a <= b for a, b in zip(values, values[1:]))
start = monotonic()
time.sleep(0.02)
assert monotonic() > start
assert monotonic is time.monotonic
print("monotonic API smoke test passed")
PYTEST
    )
}

# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
