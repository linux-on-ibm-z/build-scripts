#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : gevent
# Version       : 23.9.1
# Source repo   : https://github.com/gevent/gevent
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
#   - lsof system package needed by tests
#   - Cython-based Python library from gevent
#   - Cython extensions compiled from 2 .pyx sources
#   - NOARCH on py3.10-3.12; other Pythons have no wheel
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="gevent"
PACKAGE_VERSION="${1:-23.9.1}"
PACKAGE_URL="https://github.com/gevent/gevent"

# OPTIONAL: Build configuration
# Upstream publishes wheels for py3.10-3.12 at 23.9.1. py3.13-3.14
# have none, so those interpreters build from source.
NOARCH="true"

# REQUIRED: Dependencies
#   lsof is needed by tests for open file descriptor checks
RH_DEP_PKGS="lsof"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# CALLBACK: pre_build: in the build env, before the build
pre_build() {
    pip install "Cython>=3.0.2" "cffi>=1.12.3" "greenlet>=3.0rc3"
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    # Same invocation as upstream .github/workflows/ci.yml; GITHUB_ACTIONS makes
    # gevent.testing treat this as CI (test__core_timer.test_resolution only asserts
    # the timer fires when not on CI), and -j keeps the serial run, as CI mode
    # would otherwise force 4 workers.
    # OpenSSL 3.5.5 + TLS 1.3: the tests' clients close with the server's session
    # tickets unread, so the RST makes the server's SSL_read fail with
    # "[SYS] unknown error" instead of EOF (test_serverssl_makefile2,
    # test_backlog_is_accepted_for_address). Capping at TLS 1.2 sends no tickets
    # after the handshake.
    OPENSSL_CONF="${SCRIPT_DIR}/openssl-tls12.cnf" \
        GITHUB_ACTIONS=true python -m gevent.tests --second-chance -j "${NWORKERS}"
}

# gevent.testing.testrunner runs max(cpu_count()-1, 4) test groups in parallel;
# the wall-clock-sensitive tests (e.g. test__subprocess timeout checks) miss their
# windows under that contention, so run the groups serially.
export NWORKERS=1

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
