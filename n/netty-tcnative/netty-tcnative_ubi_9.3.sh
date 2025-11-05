#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : netty-tcnative
# Version        : 2.0.72
# Source repo    : https://github.com/netty/netty-tcnative.git
# Tested on      : UBI: 9.3
# Language       : c
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Soham Munshi <Soham.Munshi@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------
set -ex

# Variables
PACKAGE_NAME=netty-tcnative
PACKAGE_VERSION=${1:-2.0.72}
SCRIPT_DIR=$(pwd)
JAVA_PROVIDED=OpenJDK11
DISTRO="$ID-$VERSION_ID"
USER="$(whoami)"
PACKAGE_URL=https://github.com/netty/netty-tcnative.git

while getopts "yj:" opt; do
  case $opt in
    y) INSTALL_WITHOUT_CONFIRM=true ;;
    j) JAVA_PROVIDED=$OPTARG ;;
    *) 
       echo "Usage: $0 [-y] [-j {Temurin8,Temurin11,Temurin17,OpenJDK8,OpenJDK11,OpenJDK17,Semeru8,Semeru11,Semeru17}]"
       exit 1
       ;;
  esac
done

# Install dependencies
yum install -y ninja-build cmake perl gcc gcc-c++ libarchive  openssl-devel apr-devel autoconf automake libtool make tar git wget golang libstdc++-static.s390x xz-devel gzip python3-devel patch
OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)
SCRIPT_DIR=$(pwd)

if [[ "$JAVA_PROVIDED" == "Semeru11" ]]; then
   echo "Installing AdoptOpenJDK 11 (With OpenJ9) . . . "
   cd $SCRIPT_DIR
   wget https://github.com/ibmruntimes/semeru11-binaries/releases/download/jdk-11.0.24%2B8_openj9-0.46.0/ibm-semeru-open-jdk_s390x_linux_11.0.24_8_openj9-0.46.0.tar.gz
   tar -xzf ibm-semeru-open-jdk_s390x_linux_11.0.24_8_openj9-0.46.0.tar.gz
   export JAVA_HOME=$SOURCE_ROOT/jdk-11.0.24+8
   echo "Installation of AdoptOpenJDK 11 (With OpenJ9) is successful" 
elif [[ "$JAVA_PROVIDED" == "Temurin11" ]]; then
   echo "Installing AdoptOpenJDK 11 (With Hotspot) . . ."
   cd $SCRIPT_DIR
   wget https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.24%2B8/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.24_8.tar.gz
   tar -xzf OpenJDK11U-jdk_s390x_linux_hotspot_11.0.24_8.tar.gz
   export JAVA_HOME=$SOURCE_ROOT/jdk-11.0.24+8
   echo "Installation of AdoptOpenJDK 11 (With Hotspot) is successful"
elif [[ "$JAVA_PROVIDED" == "OpenJDK11" ]]; then
   yum install -y java-11-openjdk-devel
   export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
   echo "Installation of OpenJDK 11 is successful"
elif [[ "$JAVA_PROVIDED" == "Semeru17" ]]; then
   echo "Installing AdoptOpenJDK 17 (With OpenJ9) . . ."
   cd $SCRIPT_DIR
   wget https://github.com/ibmruntimes/semeru17-binaries/releases/download/jdk-17.0.12%2B7_openj9-0.46.0/ibm-semeru-open-jdk_s390x_linux_17.0.12_7_openj9-0.46.0.tar.gz
   tar -xzf ibm-semeru-open-jdk_s390x_linux_17.0.12_7_openj9-0.46.0.tar.gz
   export JAVA_HOME=$SOURCE_ROOT/jdk-17.0.12+7
   echo "Installation of AdoptOpenJDK 17 (With OpenJ9) is successful"
elif [[ "$JAVA_PROVIDED" == "Temurin17" ]]; then
   echo "Installing AdoptOpenJDK 17 (With Hotspot) . . . "
   cd $SCRIPT_DIR
   wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.12%2B7/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.12_7.tar.gz
   tar -xzf OpenJDK17U-jdk_s390x_linux_hotspot_17.0.12_7.tar.gz
   export JAVA_HOME=$SOURCE_ROOT/jdk-17.0.12+7
   echo "Installation of AdoptOpenJDK 17 (With Hotspot) is successful"
elif [[ "$JAVA_PROVIDED" == "OpenJDK17" ]]; then
   yum install -y java-17-openjdk java-17-openjdk-devel
   java_version=`ls /usr/lib/jvm/ | grep java-17-openjdk-17.*`
   export JAVA_HOME=/usr/lib/jvm/`echo $java_version | cut -d' ' -f1`
   echo "Installation of OpenJDK 17 is successful"
elif [[ "$JAVA_PROVIDED" == "Semeru8" ]]; then
   echo "Installing AdoptOpenJDK 8 (With OpenJ9) . . ."
   cd $SCRIPT_DIR
   wget https://github.com/ibmruntimes/semeru8-binaries/releases/download/jdk8u422-b05_openj9-0.46.0/ibm-semeru-open-jdk_s390x_linux_8u422b05_openj9-0.46.0.tar.gz
   tar -xzf ibm-semeru-open-jdk_s390x_linux_8u422b05_openj9-0.46.0.tar.gz
   export JAVA_HOME=$SOURCE_ROOT/jdk8u422-b05
   echo "Installation of AdoptOpenJDK 8 (With OpenJ9) is successful"
elif [[ "$JAVA_PROVIDED" == "OpenJDK8" ]]; then
   yum install -y java-1.8.0-openjdk-devel.s390x
   update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/java-1.8.0-openjdk/bin/java" 20
   update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/java-1.8.0-openjdk/bin/javac" 20
   update-alternatives --set java "/usr/lib/jvm/java-1.8.0-openjdk/bin/java"
   update-alternatives --set javac "/usr/lib/jvm/java-1.8.0-openjdk/bin/javac"
   export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
   echo "Installation of OpenJDK 8 is successful"
elif [[ "$JAVA_PROVIDED" == "Temurin8" ]]; then
   cd $SCRIPT_DIR
   wget ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz
   tar xvfz libffi-3.2.1.tar.gz
   cd libffi-3.2.1
   ./configure --prefix=/usr/local
   make
   make install
   ldconfig
   ldconfig /usr/local/lib64
   echo "Installing AdoptOpenJDK8 + OpenJ9 "
   cd $SCRIPT_DIR
   wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u282-b08/OpenJDK8U-jdk_s390x_linux_hotspot_8u282b08.tar.gz
   tar xzf OpenJDK8U-jdk_s390x_linux_hotspot_8u282b08.tar.gz -C /opt/
   export JAVA_HOME=/opt/jdk8u282-b08
   export JAVA_TOOL_OPTIONS='-Xmx2048M'
   echo "Installation of AdoptOpenJDK 8 (With Hotspot) is successful"                   	
else
        echo "$JAVA_PROVIDED is not supported, Please use valid variant from {Semeru8, OpenJDK8, Temurin8, Semeru11, Temurin11, OpenJDK11, Semeru17, Temurin17, OpenJDK17} only"
        exit 1
fi

export PATH=$JAVA_HOME/bin:$PATH
echo "Java version is :"
java -version
cd $SCRIPT_DIR
git clone $PACKAGE_URL
cd netty-tcnative
git checkout netty-tcnative-parent-${PACKAGE_VERSION}.Final
cd $SCRIPT_DIR/netty-tcnative
sed -i '96,96 s/main/patch-s390x-Sep2024/g' pom.xml
sed -i '100,100 s/cccf8525db8a57153d3cb3e22efed2db4b71a8ab/d40d43c5e00d8adfbaa88d5cf521d52f0549464c/g' pom.xml
sed -i '87,87 s/boringssl.googlesource.com/github.com\/linux-on-ibm-z/g' boringssl-static/pom.xml
sed -i '91,91 s/{boringsslHome}/{boringsslHome}\/ssl;${boringsslHome}\/crypto/g' boringssl-static/pom.xml
sed -i '95,95 s/{boringsslHome}/{boringsslHome}\/ssl -L${boringsslHome}\/crypto/g' boringssl-static/pom.xml
sed -i '124,124 s/{boringsslBuildDir}/{boringsslBuildDir}\/ssl;${boringsslBuildDir}\/crypto;${boringsslBuildDir}\/decrepit/g' boringssl-static/pom.xml
sed -i '125,125 s/ssl.lib;crypto.lib/ssl.lib;crypto.lib;decrepit.lib/g' boringssl-static/pom.xml
sed -i '379,379 s/{boringsslBuildDir}/{boringsslBuildDir}\/ssl -L${boringsslBuildDir}\/crypto -L${boringsslBuildDir}\/decrepit -ldecrepit/g' boringssl-static/pom.xml
sed -i '582,582 s/{boringsslHome}/{boringsslHome}\/ssl -L${boringsslHome}\/crypto/g' boringssl-static/pom.xml
sed -i '705,705 s/{boringsslHome}/{boringsslHome}\/ssl;${boringsslHome}\/crypto/g' boringssl-static/pom.xml
sed -i '1017,1017 s/{boringsslHome}/{boringsslHome}\/ssl -L${boringsslHome}\/crypto/g' boringssl-static/pom.xml
sed -i '1467,1467 s/{boringsslHome}/{boringsslHome}\/ssl -L${boringsslHome}\/crypto/g' boringssl-static/pom.xml 
if  ./mvnw clean install; then
    echo "------------------$PACKAGE_NAME:Installation_Success---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Pass |  Installation_Success"
	export LD_LIBRARY_PATH=$SOURCE_ROOT/netty-tcnative/openssl-dynamic/target/native-build/.libs/:$LD_LIBRARY_PATH
else
    echo "------------------$PACKAGE_NAME:Installation_Failed-------------------------"
    echo "$PACKAGE_VERSION $PACKAGE_NAME"
    echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Fail |  Installation_Failed"
	export LD_LIBRARY_PATH=$SOURCE_ROOT/netty-tcnative/openssl-dynamic/target/native-build/.libs/:$LD_LIBRARY_PATH
fi
