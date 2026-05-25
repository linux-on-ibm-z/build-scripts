#!/bin/bash -e
# ----------------------------------------------------------------------------
# 
# Package       : onnxruntime
# Version       : v1.22.1
# Source repo   : https://github.com/microsoft/onnxruntime.git
# Tested on     : UBI:9.7
# Language      : Python
# Travis-Check  : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Viddya <Viddya@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

#variables
PACKAGE_NAME=onnxruntime
PACKAGE_VERSION=${1:-v1.22.1}
PACKAGE_URL=https://github.com/microsoft/onnxruntime.git

# Install dependencies
python -m pip install numpy setuptools wheel build packaging "cmake>=3.28,<4.0" pytest

# Add user's local bin to PATH for user-installed packages
export PATH="$HOME/.local/bin:$PATH"

# Make sure the pip-installed cmake takes precedence over the system one
SITE_PACKAGES=$(python -c 'import site; print(site.getsitepackages()[0])' 2>/dev/null || python -c 'import site; print(site.getusersitepackages())')
export PATH="$SITE_PACKAGES/bin:$PATH"

CMAKE_BIN="$(which cmake)"
PYTHON_BIN="$(which python)"

# Verify cmake is found
if [ -z "$CMAKE_BIN" ]; then
    echo "ERROR: cmake not found in PATH"
    echo "PATH=$PATH"
    exit 1
fi

echo "Using CMAKE: $CMAKE_BIN"
echo "Using PYTHON: $PYTHON_BIN"

# Remove existing directory if it exists
if [ -d "$PACKAGE_NAME" ]; then
    echo "Removing existing $PACKAGE_NAME directory..."
    rm -rf $PACKAGE_NAME
fi

#clone repository
git clone -b $PACKAGE_VERSION --depth 1 $PACKAGE_URL
cd $PACKAGE_NAME

export PIP_NO_BUILD_ISOLATION=1
export PIP_NO_DEPS=1

#install
if ! (./build.sh --config Release --build_wheel --parallel --skip_tests \
  --allow_running_as_root \
  --cmake_path "$CMAKE_BIN" \
  --cmake_extra_defines \
    onnxruntime_BUILD_UNIT_TESTS=OFF \
    "Python_EXECUTABLE=$PYTHON_BIN"); then
    echo "------------------$PACKAGE_NAME:Build_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Build_Fails"
    exit 1
fi

# Install the built wheel
if ! (python -m pip install build/Linux/Release/dist/*.whl); then
    echo "------------------$PACKAGE_NAME:Install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

echo "------------------$PACKAGE_NAME:Install_success-------------------------"

# Go back to parent directory to avoid import conflicts
cd ..

#test
# Create test file
cat > test_onnxruntime.py << 'EOF'
def test_onnxruntime_import():
    import onnxruntime
    assert onnxruntime is not None
    print(f"onnxruntime version: {onnxruntime.__version__}")
EOF

if ! (pytest test_onnxruntime.py -v); then
    echo "------------------$PACKAGE_NAME:Install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:Install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
