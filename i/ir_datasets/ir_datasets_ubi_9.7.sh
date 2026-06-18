#!/usr/bin/env bash
# -----------------------------------------------------------------------------
#
# Package       : ir_datasets
# Version       : 0.5.11
# Source repo   : https://github.com/allenai/ir_datasets
# Tested on     : UBI:9.7
# Language      : Python
# Ci-Check      : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Vansh <vansh@ibm.com>
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=ir_datasets
PACKAGE_VERSION=${1:-v0.5.11}
PACKAGE_URL=https://github.com/allenai/ir_datasets

PYARROW_VERSION=${PYARROW_VERSION:-21.0.0}
PYTHON_CMD=${PYTHON_CMD:-python3.11}

ROOT_DIR=$(pwd)
ARROW_SRC_DIR="$ROOT_DIR/arrow"
ARROW_INSTALL_DIR="$ROOT_DIR/arrow-install"
ARROW_BUILD_DIR="$ROOT_DIR/arrow-build"

# Install dependencies
yum install -y \
    git \
    gcc \
    gcc-c++ \
    make \
    cmake \
    libffi-devel \
    openssl-devel \
    zlib-devel \
    bzip2-devel \
    xz-devel \
    libxml2-devel \
    libxslt-devel \
    pcre-devel \
    python3.11 \
    python3.11-pip \
    python3.11-devel

# Upgrade pip and install build tools
$PYTHON_CMD -m pip install --upgrade \
    "pip<25" \
    "setuptools>=74,<75" \
    "wheel<0.45" \
    build \
    pytest

build_and_install_pyarrow() {
    echo "Building pyarrow ${PYARROW_VERSION} from source with ${PYTHON_CMD}..."

    rm -rf "$ARROW_INSTALL_DIR" "$ARROW_BUILD_DIR" "$ARROW_SRC_DIR"

    git clone -b "apache-arrow-${PYARROW_VERSION}" https://github.com/apache/arrow.git "$ARROW_SRC_DIR"

    ########################################
    # Build Arrow C++
    ########################################

    mkdir -p "$ARROW_BUILD_DIR"

    cmake -S "$ARROW_SRC_DIR/cpp" -B "$ARROW_BUILD_DIR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$ARROW_INSTALL_DIR" \
        -DARROW_BUILD_TESTS=OFF \
        -DARROW_BUILD_BENCHMARKS=OFF \
        -DARROW_BUILD_UTILITIES=OFF \
        -DARROW_BUILD_STATIC=OFF \
        -DBUILD_SHARED_LIBS=ON \
        -DARROW_DATASET=ON \
        -DARROW_FLIGHT=ON \
        -DARROW_HDFS=ON \
        -DARROW_JEMALLOC=ON \
        -DARROW_MIMALLOC=ON \
        -DARROW_ORC=ON \
        -DARROW_PARQUET=ON \
        -DARROW_PYTHON=ON \
        -DARROW_S3=OFF \
        -DARROW_DEPENDENCY_SOURCE=BUNDLED \
        -DARROW_WITH_BROTLI=ON \
        -DARROW_WITH_BZ2=ON \
        -DARROW_WITH_LZ4=ON \
        -DARROW_WITH_SNAPPY=ON \
        -DARROW_WITH_ZLIB=ON \
        -DARROW_WITH_ZSTD=ON \
        -DARROW_WITH_THRIFT=ON \
        -DCMAKE_CXX_STANDARD=17

    cmake --build "$ARROW_BUILD_DIR" -j"$(nproc)"
    cmake --install "$ARROW_BUILD_DIR"

    ########################################
    # Arrow environment
    ########################################

    export ARROW_HOME="$ARROW_INSTALL_DIR"

    if [ -d "$ARROW_HOME/lib64" ]; then
        export CMAKE_PREFIX_PATH="$ARROW_HOME/lib64/cmake"
        export LD_LIBRARY_PATH="$ARROW_HOME/lib64:${LD_LIBRARY_PATH:-}"
        export PKG_CONFIG_PATH="$ARROW_HOME/lib64/pkgconfig:${PKG_CONFIG_PATH:-}"
    else
        export CMAKE_PREFIX_PATH="$ARROW_HOME/lib/cmake"
        export LD_LIBRARY_PATH="$ARROW_HOME/lib:${LD_LIBRARY_PATH:-}"
        export PKG_CONFIG_PATH="$ARROW_HOME/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
    fi

    ########################################
    # Build PyArrow
    ########################################

    $PYTHON_CMD -m pip install \
        setuptools-scm \
        cython \
        numpy \
        build


    cd "$ARROW_SRC_DIR/python"
    rm -rf build dist *.egg-info

    $PYTHON_CMD setup.py build_ext \
        --build-type=release \
        --with-flight \
        --with-parquet \
        --with-dataset \
        --bundle-arrow-cpp

    $PYTHON_CMD -m build --wheel

    PYARROW_WHEEL=$(ls dist/*.whl | head -1)
    echo "Installing generated pyarrow wheel: $PYARROW_WHEEL"
    $PYTHON_CMD -m pip install "$PYARROW_WHEEL"

    cd "$ROOT_DIR"
}

if ! $PYTHON_CMD -c "import pyarrow" >/dev/null 2>&1; then
    echo "pyarrow is not installed for $PYTHON_CMD. Building from source..."
    build_and_install_pyarrow
else
    echo "pyarrow is already installed for $PYTHON_CMD, skipping pyarrow build."
fi

# Clone repository
rm -rf "$ROOT_DIR/$PACKAGE_NAME"
git clone "$PACKAGE_URL" "$ROOT_DIR/$PACKAGE_NAME"
cd "$ROOT_DIR/$PACKAGE_NAME"
git checkout "$PACKAGE_VERSION"

# Build wheel
echo "Building $PACKAGE_NAME wheel with $PYTHON_CMD..."
$PYTHON_CMD -m build --wheel

# Install the package
WHEEL_FILE=$(ls dist/*.whl | head -1)
if ! $PYTHON_CMD -m pip install "$WHEEL_FILE" ; then
    echo "------------------$PACKAGE_NAME:Install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

echo "Build and installation completed successfully."

# Run smoke tests
echo "Running smoke tests with $PYTHON_CMD..."
if ! $PYTHON_CMD - <<'EOF' > test_logs.txt 2>&1
import ir_datasets

print("ir_datasets version:", ir_datasets.__version__)

dataset = ir_datasets.load("cranfield")
print(dataset)

assert dataset is not None

print("Smoke test PASSED")
EOF
then
    echo "------------------$PACKAGE_NAME:Test_fails-------------------------------------"
    echo "Test logs saved to test_logs.txt"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Test_Fails"
    exit 1
fi

echo "All tests passed successfully!"
echo "Test logs saved to test_logs.txt"

# Run pytest tests
echo "Running pytest tests with $PYTHON_CMD..."
if [ -d test ]; then
    cd test
        if ! $PYTHON_CMD -m pytest -v --tb=short > ../pytest_logs.txt 2>&1; then
            echo "------------------$PACKAGE_NAME:Pytest_fails-------------------------------------"
            echo "Pytest logs saved to pytest_logs.txt"
            echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Pytest_Fails"
            cd ..
            exit 1
        fi
        cd ..
        echo "Pytest tests passed successfully!"
        echo "Pytest logs saved to pytest_logs.txt"
else
    echo "No tests directory found, skipping pytest"
fi
