#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : erlang
# Version        : 28.0.2
# Source repo    : https://github.com/erlang/otp
# Tested on      : UBI: 9.3
# Language       : erlang
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Yasir Ashfaq <Yasir.Ashfaq1@ibm.com>
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
PACKAGE_NAME=erlang
PACKAGE_VERSION=${1:-28.0.2}
SCRIPT_DIR=$(pwd)
PACKAGE_URL=https://github.com/erlang/otp/releases/download/OTP-${PACKAGE_VERSION}/otp_src_${PACKAGE_VERSION}.tar.gz
JAVA_PROVIDED=OpenJDK11
DISTRO="$ID-$VERSION_ID"
BUILD_ENV=$HOME/setenv.sh
true > $BUILD_ENV
while getopts "j:" opt; do
  case $opt in
    j) JAVA_PROVIDED=$OPTARG ;;
    *) 
       echo "Usage: $0 [-y] [-j {Temurin17,Temurin21,OpenJDK17,OpenJDK21}]"
       exit 1
       ;;
  esac
done
# Install dependencies
yum install -y autoconf gawk gcc gcc-c++ gzip libxml2-devel libxslt ncurses-devel openssl-devel make tar unixODBC-devel wget
yum install -y yum-utils
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/AppStream/s390x/os/
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/BaseOS/s390x/os/
wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official
mv RPM-GPG-KEY-CentOS-Official /etc/pki/rpm-gpg/.
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official
yum install -y flex
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
   elif [[ "$JAVA_PROVIDED" == "Semeru11" ]]; then 
		cd $SCRIPT_DIR
        wget -O semeru11.tar.gz https://github.com/ibmruntimes/semeru11-binaries/releases/download/jdk-11.0.26%2B4_openj9-0.49.0/ibm-semeru-open-jdk_s390x_linux_11.0.26_4_openj9-0.49.0.tar.gz
        mkdir -p /opt/semeru11
	    tar -zxf semeru11.tar.gz -C /opt/semeru11 --strip-components 1
        export LS_JAVA_HOME=/opt/semeru11
        echo "Installation of semeru11 is successful"
   elif [[ "$JAVA_PROVIDED" == "Semeru17" ]]; then
		cd $SCRIPT_DIR
        wget -O semeru17.tar.gz https://github.com/ibmruntimes/semeru17-binaries/releases/download/jdk-17.0.14%2B7_openj9-0.49.0/ibm-semeru-open-jdk_s390x_linux_17.0.14_7_openj9-0.49.0.tar.gz
        mkdir -p /opt/semeru17
	    tar -zxf semeru17.tar.gz -C /opt/semeru17 --strip-components 1
        export LS_JAVA_HOME=/opt/semeru17
        echo "Installation of semeru17 is successful" 
   elif [[ "$JAVA_PROVIDED" == "Semeru8" ]]; then
		cd $SCRIPT_DIR
        wget -O semeru8.tar.gz https://github.com/ibmruntimes/semeru8-binaries/releases/download/jdk8u442-b06_openj9-0.49.0/ibm-semeru-open-jdk_s390x_linux_8u442b06_openj9-0.49.0.tar.gz
        mkdir -p /opt/semeru8
	    tar -zxf semeru8.tar.gz -C /opt/semeru8 --strip-components 1
        export LS_JAVA_HOME=/opt/semeru8
        echo "Installation of semeru8 is successful" 
   elif [[ "$JAVA_PROVIDED" == "Semeru21" ]]; then	
		cd $SCRIPT_DIR
        wget -O semeru21.tar.gz https://github.com/ibmruntimes/semeru21-binaries/releases/download/jdk-21.0.6%2B7_openj9-0.49.0/ibm-semeru-open-jdk_s390x_linux_21.0.6_7_openj9-0.49.0.tar.gz
        mkdir -p /opt/semeru21
	    tar -zxf semeru21.tar.gz -C /opt/semeru21 --strip-components 1
        export LS_JAVA_HOME=/opt/semeru21
        echo "Installation of semeru21 is successful" 
   elif [[ "$JAVA_PROVIDED" == "Temurin11" ]]; then
        echo "Installing Temurin 11 . . ."
        cd $SCRIPT_DIR
        wget -O temurin11.tar.gz https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.26%2B4/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.26_4.tar.gz
        tar -C /opt/java -xzf temurin11.tar.gz
        mkdir -p /opt/temurin11
        tar -zxf temurin11.tar.gz -C /opt/temurin11 --strip-components 1
        export LS_JAVA_HOME=/opt/temurin11
        echo "Installation of Temurin11 is successful"
   elif [[ "$JAVA_PROVIDED" == "OpenJDK11" ]]; then
        yum install -y java-11-openjdk-devel   
        export JAVA_HOME=/usr/lib/jvm/java-11-openjdk 
		echo "Installation of OpenJDK 11 is successful"	
   elif [[ "$JAVA_PROVIDED" == "OpenJDK8" ]]; then
        yum install -y java-1.8.0-openjdk-devel
        export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
		echo "Installation of OpenJDK 8 is successful"	
else
        echo "$JAVA_PROVIDED is not supported, Please use valid variant from {Semeru8, Semeru11, Semeru17, Semeru21, Temurin11, Temurin17, Temurin21, OpenJDK8, OpenJDK11 OpenJDK17, OpenJDK21} only"
        exit 1
fi

echo "export LS_JAVA_HOME=$LS_JAVA_HOME" >> "$BUILD_ENV"
export PATH=$LS_JAVA_HOME/bin:$PATH
echo "export PATH=$PATH" >> $BUILD_ENV
java -version
cd $SCRIPT_DIR
wget $PACKAGE_URL
tar zxf otp_src_${PACKAGE_VERSION}.tar.gz
mv otp_src_${PACKAGE_VERSION} erlang
chmod -Rf 755 erlang
cd $SCRIPT_DIR
cd erlang
export ERL_TOP=$(pwd)
./configure --prefix=/usr
make -j$(nproc)
make install
echo "Build and install erlang successfully"
if [ ! -x /bin/erl ]; then
        echo "------------------$PACKAGE_NAME:Installation failed-------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Fail |  Install_Failure"
		exit 2
else
        echo "------------------$PACKAGE_NAME installation completed. Please check the Usage to start the service---------------------"		
        echo "$PACKAGE_URL $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Pass |  Install_Success"
fi
#Run Tests
echo "Running Erlang tests..."
cd $SCRIPT_DIR/erlang
make release_tests -j$(nproc)
cd release/tests/test_server
if ! $ERL_TOP/bin/erl -s ts install -s ts smoke_test batch -s init stop; then
			echo "------------------$PACKAGE_NAME:Installation_Completed_Tests_Failed-------------------------"
			echo "$PACKAGE_VERSION $PACKAGE_NAME"
			echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Fail | Installation_Completed_Tests_Failed"
			exit 2
else
			echo "------------------$PACKAGE_NAME Installation_Completed_Tests_Passed---------------------"		
			echo "$PACKAGE_URL $PACKAGE_NAME"
			echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Pass | Installation_Completed_Tests_Passed "
			echo "To set the Environmental Variables needed for erlang, please run: source $HOME/setenv.sh"
			exit 0
fi
