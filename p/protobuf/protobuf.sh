#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : protobuf
# Version       : v3.20.2
# Source repo   : https://github.com/protocolbuffers/protobuf
# Tested on     : UBI:9.8
# Language      : C/C++
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
#   - Python package lives in python/ subdirectory, so custom_install builds it there
#   - assertRaisesRegexp removed in Python 3.12; patched to assertRaisesRegex
#   - C++ library built with autoconf; installed into artifact prefix for consumers
#   - Compiled extension makes the wheel architecture-specific
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="protobuf"
PACKAGE_VERSION="${1:-v3.20.2}"
PACKAGE_URL="https://github.com/protocolbuffers/protobuf"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="protobuf"
# ARTIFACT_VERSION is the dotted release number consumers pin
ARTIFACT_VERSION="${PACKAGE_VERSION#v}"
LICENSE_SPDX="BSD-3-Clause"

# REQUIRED: Dependencies
RH_DEP_PKGS="gcc-c++ make autoconf automake libtool"

# CALLBACK: post_clone: after the clone, worktree at PACKAGE_VERSION
post_clone() {
    if [[ -f "${SCRIPT_DIR}/patches/${PACKAGE_NAME}.patch" ]]; then
        log_info "Applying generated patch..."
        git apply "${SCRIPT_DIR}/patches/${PACKAGE_NAME}.patch"
    fi
    if [[ "${PYTHON_VERSION}" == "3.14" && -f "${SCRIPT_DIR}/patches/protobuf-py3.14.patch" ]]; then
        log_info "Applying py3.14 patch..."
        git apply "${SCRIPT_DIR}/patches/protobuf-py3.14.patch"
    fi
}

# CALLBACK: pre_build: in the build env, before the build
pre_build() {
    ./autogen.sh
    ./configure --disable-shared
    make -C src protoc -j"$(nproc)"
}

# CALLBACK: custom_install: replaces the default install step
custom_install() {
    local src_dir="${PWD}"
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    # Install the native C++ library into the artifact prefix
    ./configure --prefix="${prefix}" --disable-shared
    make -j"$(nproc)"
    make install

    # Build the Python wheel using the compiled protoc
    PROTOC="${src_dir}/src/protoc" python -m build \
        --no-isolation --wheel --outdir "${src_dir}/dist" \
        python/
    cp "${src_dir}/dist"/*.whl "${OUTPUT_DIR}/"

    # Publish the artifact
    _cleanup_artifact "${prefix}"
    _copy_license "${prefix}"
    _generate_env_sh "${prefix}" "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}"
    generate_artifact_manifest "${prefix}" "${PROVIDES_ARTIFACT}" \
        "${ARTIFACT_VERSION}" "${PACKAGE_URL}" "${LICENSE_SPDX}"
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    cd python/
    pytest google/protobuf/internal/ \
        --import-mode=importlib \
        -o addopts= \
        -x
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
