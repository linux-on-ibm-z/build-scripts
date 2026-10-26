#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : tqdm
# Version       : v4.67.1
# Source repo   : https://github.com/tqdm/tqdm
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
#   - tqdm is a pure-Python library
#   - Published noarch wheel installed via NOARCH, not rebuilt from source
#   - No compiled extensions; no extra system packages needed
#   - pytest-asyncio is required at test time by tests/tests_asyncio.py
#   - The nbval sanitize config is patched to ignore non-deterministic ETA
#     timing values in tests_notebook.ipynb (e.g. "00:02" vs "00:00")
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# PACKAGE_VERSION defaults to v4.67.1, overridable as $1
# =============================================================================
PACKAGE_NAME="tqdm"
PACKAGE_VERSION="${1:-v4.67.1}"
PACKAGE_URL="https://github.com/tqdm/tqdm"

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
    # tests/tests_asyncio.py contains async def test functions that require
    # an asyncio pytest plugin; without it all 7 tests fail with
    # "async def functions are not natively supported".
    pip install pytest-asyncio

    # tests_notebook.ipynb::Cell 4 ("reset") compares tqdm's ETA timer string
    # (e.g. "00:02") which is non-deterministic across machines.  Patch the
    # nbval sanitize config that tox passes via --nbval-sanitize-with so the
    # time-remaining field is replaced with a stable placeholder before the
    # output comparison is performed.
    mkdir -p .meta
    if ! grep -q 'NBVAL_ETA' .meta/nbval.ini 2>/dev/null; then
        cat >> .meta/nbval.ini <<'EOF'

# Added by build script: normalise non-deterministic ETA / elapsed time values
# produced by tqdm progress bars so nbval output comparisons are stable.
[regex]
# Matches timestamps like [00:00<00:02, ?it/s] or [01:23<00:05, 4.56it/s]
# and replaces the two HH:MM:SS fields with a fixed token.
NBVAL_ETA=\[\d{2}:\d{2}<\d{2}:\d{2},\s[^]]+\]
NBVAL_ETA_REPLACEMENT=[NBVAL_ETA]
EOF
    fi
}

# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
