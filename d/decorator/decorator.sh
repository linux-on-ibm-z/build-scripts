
#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : decorator
# Version       : 4.4.2
# Source repo   : https://github.com/micheles/decorator
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
#   - decorator is a pure-Python library
#   - Published noarch wheel installed via NOARCH, not rebuilt from source
#   - No compiled extensions; no extra system packages needed
#   - decorator 4.4.2 tests use asyncio.get_event_loop() which requires an
#     explicit event loop on Python 3.10+; a conftest.py is injected at test
#     time to set one up before the session starts
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# PACKAGE_VERSION defaults to 4.4.2, overridable as $1
# =============================================================================
PACKAGE_NAME="decorator"
PACKAGE_VERSION="${1:-4.4.2}"
PACKAGE_URL="https://github.com/micheles/decorator"

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
custom_test_command() {
    # Python 3.10+ removed the implicit event loop creation from get_event_loop().
    # decorator 4.4.2's tests call get_event_loop() without setting one first,
    # so we inject a conftest.py that sets up a loop before the session starts.
    cat > src/tests/conftest.py <<'EOF'
import asyncio
import pytest

@pytest.fixture(autouse=True, scope="session")
def set_event_loop():
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    yield loop
    loop.close()
EOF
    pytest src/tests/test.py
}
# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh" 