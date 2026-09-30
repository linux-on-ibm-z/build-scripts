#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : onnxruntime
# Version       : v1.22.1
# Source repo   : https://github.com/microsoft/onnxruntime
# Tested on     : UBI:9.7
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Viddya K <viddya.k@ibm.com>
#
# Notes:
#   - onnxruntime uses a custom CMake-based build system (./build.sh), not pip/pyproject.toml
#   - Requires cmake>=3.28; the system cmake on UBI 9 is typically older, so cmake is
#     installed via pip in pre_build() to ensure the required version is available
#   - Wheel is produced in build/Linux/Release/dist/ and staged to dist/ for the template
#     to pick up for auditwheel repair and packaging
#   - Unit tests are disabled at build time (onnxruntime_BUILD_UNIT_TESTS=OFF) to reduce
#     build time; a post-install import test validates the wheel
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="onnxruntime"
PACKAGE_VERSION="${1:-v1.22.1}"
PACKAGE_URL="https://github.com/microsoft/onnxruntime"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
# Note: cmake is NOT listed here; it is installed via pip in pre_build() to
# ensure cmake>=3.28 since the system cmake on UBI 9 is typically too old.
RH_DEP_PKGS="git gcc gcc-c++ make python3-devel python3-pip"
DEB_DEP_PKGS="git gcc g++ make python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git gcc gcc-c++ make python3-devel python3-pip"

# =============================================================================
# CALLBACK: pre_build
# Install cmake>=3.28 and Python build dependencies
# Note: Runs INSIDE .venv-build
# =============================================================================
pre_build() {
    log_info "Installing cmake>=3.28 and Python build dependencies..."
    # onnxruntime v1.22+ requires cmake>=3.28; system cmake on UBI 9 is older.
    # Installing via pip places cmake in the venv bin/ so it takes precedence.
    pip install "cmake>=3.28,<4.0" numpy packaging
}

# =============================================================================
# CALLBACK: custom_install
# Build the onnxruntime wheel using its native build system
# =============================================================================
custom_install() {
    log_info "Building onnxruntime wheel via ./build.sh..."

    CMAKE_BIN="$(which cmake)"
    PYTHON_BIN="$(which python)"

    if [[ -z "$CMAKE_BIN" ]]; then
        log_error "cmake not found in PATH after pre_build — cannot build"
        return 1
    fi

    log_info "cmake: $CMAKE_BIN ($(cmake --version | head -1))"
    log_info "python: $PYTHON_BIN ($(python --version))"

    ./build.sh \
        --config Release \
        --build_wheel \
        --parallel \
        --skip_tests \
        --allow_running_as_root \
        --cmake_path "$CMAKE_BIN" \
        --cmake_extra_defines \
            onnxruntime_BUILD_UNIT_TESTS=OFF \
            "Python_EXECUTABLE=$PYTHON_BIN"

    # Stage the produced wheel in dist/ so the template detects it,
    # runs auditwheel, and packages it into the output directory.
    mkdir -p dist
    cp build/Linux/Release/dist/*.whl dist/
    log_info "Wheel staged in dist/: $(ls dist/*.whl)"
}

# =============================================================================
# CALLBACK: custom_test_command
# Validate the installed onnxruntime wheel
# =============================================================================
custom_test_command() {
    log_info "Running onnxruntime import and smoke test..."
    # cd to /tmp so Python imports the installed wheel from site-packages
    # rather than shadowing it with the local source directory (/workspace/onnxruntime/onnxruntime)
    cd /tmp
    python -c "
import onnxruntime
print('onnxruntime version:', onnxruntime.__version__)
print('Available providers:', onnxruntime.get_available_providers())
assert 'CPUExecutionProvider' in onnxruntime.get_available_providers(), \
    'CPUExecutionProvider not available'
print('onnxruntime smoke test passed')
"
}

# =============================================================================
# Execute the build (invokes the Python template)
# =============================================================================
source "${SCRIPT_DIR}/../../templates/python.sh"
