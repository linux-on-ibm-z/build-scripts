#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : logstash
# Version        : 9.1.0
# Source repo    : https://github.com/elastic/logstash
# Tested on      : UBI: 9.3
# Language       : go
# Travis-Check   : Java
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Vibhuti Sawant <vibhuti.sawant@ibm.com>
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
PACKAGE_NAME=logstash
PACKAGE_VERSION=${1:-9.1.0}
SCRIPT_DIR=$(pwd)
PACKAGE_URL=https://artifacts.elastic.co/downloads/logstash/logstash-oss-"$PACKAGE_VERSION"-linux-aarch64.tar.gz
JAVA_PROVIDED=OpenJDK17
DISTRO="$ID-$VERSION_ID"
ROOT_USER="$(whoami)"
BUILD_ENV=$HOME/setenv.sh
true > $BUILD_ENV

while getopts "yj:" opt; do
  case $opt in
    y) INSTALL_WITHOUT_CONFIRM=true ;;
    j) JAVA_PROVIDED=$OPTARG ;;
    *) 
       echo "Usage: $0 [-y] [-j {Temurin17,Temurin21,OpenJDK17,OpenJDK21}]"
       exit 1
       ;;
  esac
done

# Install dependencies
yum install -y gcc make tar wget 

OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)
SCRIPT_DIR=$(pwd)

if [[ "$JAVA_PROVIDED" == "Temurin17" ]]; then
        # Install Temurin 17
        echo "Installing Temurin 17 . . ."
        cd $SCRIPT_DIR
        wget -O temurin17.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.13_11.tar.gz
        mkdir -p /opt/temurin17
        tar -zxf temurin17.tar.gz -C /opt/temurin17 --strip-components 1
        export LS_JAVA_HOME=/opt/temurin17
        echo "Installation of Temurin17 is successful"

   elif [[ "$JAVA_PROVIDED" == "Temurin21" ]]; then
        # Install Temurin 21
        echo "Installing Temurin 21 . . . "
        cd $SCRIPT_DIR
        wget -O temurin21.tar.gz https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_s390x_linux_hotspot_21.0.5_11.tar.gz
        mkdir -p /opt/temurin21
        tar -zxf temurin21.tar.gz -C /opt/temurin21 --strip-components 1
        export LS_JAVA_HOME=/opt/temurin21
        echo "Installation of Temurin21 is successful"

   elif [[ "$JAVA_PROVIDED" == "OpenJDK21" ]]; then
        echo "Installing OpenJDK 21 . . ."
        yum install -y java-21-openjdk-devel
        export LS_JAVA_HOME=/usr/lib/jvm/java-21-openjdk
        echo "Installation of OpenJDK 21 is successful"
		
   elif [[ "$JAVA_PROVIDED" == "OpenJDK17" ]]; then
        echo "Installing OpenJDK 17 . . ."
        yum install -y java-17-openjdk-devel
        export LS_JAVA_HOME=/usr/lib/jvm/java-17-openjdk
        echo "Installation of OpenJDK 17 is successful"
		
else
        echo "$JAVA_PROVIDED is not supported, Please use valid variant from {Temurin17, Temurin21, OpenJDK17, OpenJDK21} only"
        exit 1
fi

echo "export LS_JAVA_HOME=$LS_JAVA_HOME" >> "$BUILD_ENV"
export PATH=$LS_JAVA_HOME/bin:$PATH
echo "export PATH=$PATH" >> $BUILD_ENV
java -version
cd $SCRIPT_DIR
wget -q $PACKAGE_URL
mkdir -p /usr/share/logstash
tar -xzf logstash-oss-"$PACKAGE_VERSION"-linux-aarch64.tar.gz -C /usr/share/logstash --strip-components 1
ln -sf /usr/share/logstash/bin/* /usr/bin
if [[ -z "$(cut -d: -f1 /etc/group | grep elastic)" ]]; then
    echo "Creating group elastic."
    /usr/sbin/groupadd elastic # If group is not already created
fi
chown "$ROOT_USER:elastic" -R /usr/share/logstash
if [ ! -x /usr/bin/logstash ]; then
        echo "------------------$PACKAGE_NAME:Installation failed-------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Fail |  Install_Failure"
		exit 2
else
        echo "------------------$PACKAGE_NAME installation completed. Please check the Usage to start the service---------------------"		
        echo "$PACKAGE_URL $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Pass |  Install_Success"
		echo "To set the Environmental Variables needed for Logstash, please run: source $HOME/setenv.sh"
		exit 0
fi
