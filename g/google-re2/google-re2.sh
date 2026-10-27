#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : google-re2
# Version       : 2024-07-02
# Source repo   : https://github.com/google/re2
# Tested on     : UBI:9.3
# Language      : C++ / Python
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
#   - google-re2 provides Python bindings for Google's RE2 regex engine.
#   - PyPI version 1.1.20240702 corresponds to RE2 C++ GitHub tag 2024-07-02.
#   - No s390x wheel on PyPI; must build from source (NOARCH=false).
#   - Abseil C++ and RE2 C++ are built from source in pre_build().
#   - The Python wheel is also built in pre_build() from python/ subdir.
#   - A minimal stub setup.py (packages=[]) is written to the repo root so
#     the template's project detection passes without auto-discovering dirs.
#   - python/re2.py is renamed before tests to avoid shadowing the installed
#     wheel when pytest collects from that directory.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="google-re2"
PACKAGE_VERSION="${1:-2024-07-02}"
PACKAGE_URL="https://github.com/google/re2"

NOARCH="false"

RH_DEP_PKGS="git cmake make python3-devel python3-pip gcc gcc-c++"
DEB_DEP_PKGS="git cmake make python3-dev python3-pip python3-venv build-essential"
SLES_DEP_PKGS="git cmake make python3-devel python3-pip gcc gcc-c++"

ABSL_VERSION="20240116.2"
ABSL_PREFIX="${HOME}/local/absl"
RE2_PREFIX="/workspace/google-re2/install"

post_clone() {
    # Write a minimal stub setup.py at the repo root so the template's
    # project detection passes. packages=[] prevents setuptools from
    # auto-discovering re2/, lib/, install/ etc. in the repo root.
    cat > /workspace/google-re2/setup.py <<'EOF'
from setuptools import setup
setup(name="google-re2-stub", version="0.0.0", packages=[])
EOF
}

pre_build() {
    pip install --upgrade pip setuptools pybind11 build absl-py wheel

    # Build Abseil C++ from source
    git clone --depth 1 --branch "${ABSL_VERSION}" \
        https://github.com/abseil/abseil-cpp.git /tmp/abseil-cpp
    cmake -S /tmp/abseil-cpp -B /tmp/build-absl \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${ABSL_PREFIX}" \
        -DABSL_PROPAGATE_CXX_STD=ON \
        -DABSL_BUILD_TESTING=OFF \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    cmake --build /tmp/build-absl -j"$(nproc)"
    cmake --install /tmp/build-absl

    # Build RE2 C++ shared library from source
    cmake -S /workspace/google-re2 -B /tmp/build-re2 \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${RE2_PREFIX}" \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_PREFIX_PATH="${ABSL_PREFIX}/lib64/cmake/absl;${ABSL_PREFIX}/lib/cmake/absl"
    cmake --build /tmp/build-re2 -j"$(nproc)"
    cmake --install /tmp/build-re2

    # Build the Python wheel from the python/ subdir
    export CPPFLAGS="-I${RE2_PREFIX}/include -I${ABSL_PREFIX}/include"
    export LDFLAGS="-L${RE2_PREFIX}/lib64 -L${RE2_PREFIX}/lib -L${ABSL_PREFIX}/lib64 -L${ABSL_PREFIX}/lib -Wl,-rpath,${RE2_PREFIX}/lib64 -Wl,-rpath,${RE2_PREFIX}/lib"
    export LD_LIBRARY_PATH="${RE2_PREFIX}/lib64:${RE2_PREFIX}/lib:${ABSL_PREFIX}/lib64:${ABSL_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

    cd /workspace/google-re2/python
    python3 -m build --wheel --no-isolation
}

pre_test() {
    export LD_LIBRARY_PATH="${RE2_PREFIX}/lib64:${RE2_PREFIX}/lib:${ABSL_PREFIX}/lib64:${ABSL_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

    pip install /workspace/google-re2/python/dist/*.whl
    pip install pytest absl-py
}

custom_test_command() {
    export LD_LIBRARY_PATH="${RE2_PREFIX}/lib64:${RE2_PREFIX}/lib:${ABSL_PREFIX}/lib64:${ABSL_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

    # Smoke test
    python3 -c "
import re2
print('re2 module imported successfully.')
result = re2.match('h.*o', 'hello')
assert result is not None and result.group(0) == 'hello'
print('Basic match test passed:', result.group(0))
"

    # Rename python/re2.py so "import re2" resolves to the installed wheel
    [[ -f /workspace/google-re2/python/re2.py ]] && \
        mv /workspace/google-re2/python/re2.py /workspace/google-re2/python/re2_source.py

    pytest /workspace/google-re2/python/re2_test.py -v
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
