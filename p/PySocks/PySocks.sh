#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : PySocks
# Version       : 1.7.0
# Source repo   : https://github.com/Anorov/PySocks
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
#     built via direct python setup.py invocation to bypass that subprocess
#     patched in pre_test() after extraction so setup.py bdist_wheel succeeds
#
# Notes:
#   - Upstream publishes universal (py2.py3-none-any) wheels on PyPI
#   - tornado 5.1.1 setup.py checks ssl.match_hostname removed in Python 3.12;
#   - test_server==0.0.27 requires tornado<6 (uses tornado.web.asynchronous)
#   - Pure-Python library from Anorov, no compiled extension
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="PySocks"
PACKAGE_VERSION="${1:-1.7.0}"
PACKAGE_URL="https://github.com/Anorov/PySocks"

# REQUIRED: Dependencies
RH_DEP_PKGS=""
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# CALLBACK: pre_test: installs test prerequisites
pre_test() {
    # tornado 5.1.1 setup.py line 146 checks ssl.match_hostname which Python 3.12
    # removed; patch that line out after extraction so bdist_wheel succeeds.
    mkdir -p "${HOME}/wheels"
    local _tornado_src="${HOME}/tornado-5.1.1-src"
    mkdir -p "${_tornado_src}"
    curl --http1.1 -fSL --retry 5 --retry-all-errors \
        "https://files.pythonhosted.org/packages/source/t/tornado/tornado-5.1.1.tar.gz" \
        -o "${HOME}/tornado-5.1.1.tar.gz"
    tar -xf "${HOME}/tornado-5.1.1.tar.gz" --strip-components=1 -C "${_tornado_src}"
    # Remove the entire SSL-version check block (lines 143-148 in tornado 5.1.1
    # setup.py); ssl.match_hostname was dropped in Python 3.12 so the condition
    # fires, but the sed pattern '/ssl\.match_hostname/' never matched because the
    # file spells it `ssl, 'match_hostname'` (comma+quote), not `ssl.match_hostname`.
    sed -i '/if (not hasattr(ssl/,/backported the necessary changes/d' "${_tornado_src}/setup.py"
    # In Python 3.10+, collections.MutableMapping and other abstract collections were moved to collections.abc
    sed -i 's/collections\.MutableMapping/collections.abc.MutableMapping/g' "${_tornado_src}/tornado/httputil.py"
    (cd "${_tornado_src}" && python setup.py bdist_wheel -d "${HOME}/wheels") || return 1
    # Install tornado 5.1.1 first; PIP_CONSTRAINT ensures pip doesn't upgrade it
    # when test_server's unversioned "tornado" dep is resolved.
    pip install "${HOME}/wheels"/tornado-5.1.1-*.whl psutil "test_server==0.0.27"

    # test/bin/3proxy is an x86-64 ELF; it fails with "Exec format error" on
    # s390x.  Build 3proxy 0.8.13 from source; v0.7 from the GitHub mirror
    # rejects SOCKS4 with ident error (0x5c) and SOCKS5 with ACL error (0x02)
    # because it enforces stricter per-service ACL defaults than the shipped binary.
    # 0.8.13 correctly applies global "auth none"/"allow *" to all proxy types.
    local _3proxy_src="${HOME}/3proxy-0.8.13-src"
    if [ ! -x "${_3proxy_src}/src/3proxy" ]; then
        curl --http1.1 -fSL --retry 5 --retry-all-errors \
            "https://github.com/3proxy/3proxy/archive/refs/tags/0.8.13.tar.gz" \
            -o "${HOME}/3proxy-0.8.13.tar.gz"
        mkdir -p "${_3proxy_src}"
        tar -xf "${HOME}/3proxy-0.8.13.tar.gz" --strip-components=1 -C "${_3proxy_src}"
        make -C "${_3proxy_src}" -f Makefile.Linux || return 1
    fi
    cp "${_3proxy_src}/src/3proxy" test/bin/3proxy
}

# Write a pip constraints file so every pip call (including tox's venv) pins
# tornado<6; test_server==0.0.27 uses tornado.web.asynchronous removed in 6.0.
cat > "${HOME}/pip-constraints.txt" <<'EOF'
tornado<6
EOF
export PIP_CONSTRAINT="${HOME}/pip-constraints.txt"
# Make the pre-built tornado wheel visible to pip and tox
export PIP_FIND_LINKS="${HOME}/wheels"

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
