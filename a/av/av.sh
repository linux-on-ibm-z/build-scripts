#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : av
# Version       : v13.1.0
# Source repo   : https://github.com/PyAV-Org/PyAV
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
#   - No s390x wheel on PyPI; must build from source.
#   - No ffmpeg-devel in UBI 9; FFmpeg 7.0.2 is built from source in pre_build().
#   - PKG_CONFIG_PATH / LD_LIBRARY_PATH exported so the build and tests find
#     the vendored FFmpeg shared libs.
#   - The source av/ directory is renamed to av_src in pre_test() so Python
#     imports the installed wheel's compiled .so files, not the source tree.
#   - numpy is required by several test modules; installed in pre_test().
#   - 6 tests deselected in custom_test_command() as known environment limits:
#       test_encoding_h264, test_encoding_with_pts, test_max_b_frames:
#         FFmpeg built without libx264; H.264 encoding unavailable.
#       test_no_timeout, test_open_timeout, test_open_timeout_2:
#         FFmpeg built with --disable-network; HTTP protocol unavailable.
#   - custom_test_command() is required (not just pre_test) because the
#     template's standard pytest path has no mechanism to pass --deselect flags.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="av"
PACKAGE_VERSION="${1:-v13.1.0}"
PACKAGE_URL="https://github.com/PyAV-Org/PyAV"

NOARCH="false"

RH_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++ pkg-config make wget tar"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv gcc g++ pkg-config make wget tar"
SLES_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++ pkg-config make wget tar"

FFMPEG_PREFIX="/tmp/ffmpeg-build"

pre_build() {
    pip install "cython>=3.0" setuptools wheel

    if [ ! -f "${FFMPEG_PREFIX}/lib/pkgconfig/libavformat.pc" ]; then
        log_info "Building FFmpeg 7.0.2 from source..."
        mkdir -p /tmp/ffmpeg-src
        wget -q https://ffmpeg.org/releases/ffmpeg-7.0.2.tar.xz -O /tmp/ffmpeg-src/ffmpeg.tar.xz
        tar -xf /tmp/ffmpeg-src/ffmpeg.tar.xz -C /tmp/ffmpeg-src --strip-components=1
        cd /tmp/ffmpeg-src
        ./configure --prefix="${FFMPEG_PREFIX}" \
            --enable-shared --disable-static \
            --disable-doc --disable-programs \
            --disable-network --disable-debug \
            --enable-pic
        make -j"$(nproc)"
        make install
        cd /workspace/av
    fi

    export PKG_CONFIG_PATH="${FFMPEG_PREFIX}/lib/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"
    export LD_LIBRARY_PATH="${FFMPEG_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
}

pre_test() {
    export LD_LIBRARY_PATH="${FFMPEG_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    pip install numpy
    # Rename the source av/ directory so Python cannot shadow the installed
    # wheel's compiled .so files with the bare source package.
    mv /workspace/av/av /workspace/av/av_src
}

custom_test_command() {
    pytest tests \
        --deselect=tests/test_codec_context.py::TestEncoding::test_encoding_h264 \
        --deselect=tests/test_encode.py::TestBasicVideoEncoding::test_encoding_with_pts \
        --deselect=tests/test_encode.py::TestMaxBFrameEncoding::test_max_b_frames \
        --deselect=tests/test_timeout.py::TestTimeout::test_no_timeout \
        --deselect=tests/test_timeout.py::TestTimeout::test_open_timeout \
        --deselect=tests/test_timeout.py::TestTimeout::test_open_timeout_2
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
