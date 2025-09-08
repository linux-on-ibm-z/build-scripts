#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package        : keystone
# Version        : 27.0.0
# Source repo    : https://github.com/openstack/keystone
# Tested on      : UBI: 9.3
# Language       : python
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Varun Ojha <Varun.Ojha3@ibm.com>
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
PACKAGE_NAME=keystone
PACKAGE_VERSION=27.0.0
KEYSTONE_DBPASS=keystone
KEYSTONE_HOST_IP=localhost
SCRIPT_DIR=$(pwd)
CONF_URL=https://raw.githubusercontent.com/linux-on-ibm-z/build-scripts/main/k/keystone/conf

# Install dependencies
yum install -y wget openssl-devel gcc make gcc-c++ httpd httpd-devel procps sqlite-devel perl rust cargo
yum install -y python3-devel python3-mod_wsgi python3-pip pkg-config 
yum remove -y python3-requests
pip3 install --upgrade pip
yum install -y yum-utils
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/AppStream/s390x/os/
yum-config-manager --add-repo http://rpmfind.net/linux/centos-stream/9-stream/BaseOS/s390x/os/ 	
yum config-manager --set-enabled ubi-9-codeready-builder
yum config-manager --set-enabled ubi-9-codeready-builder-rpms
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
# add repo for installing bison,flex
yum config-manager --add-repo https://mirror.stream.centos.org/9-stream/CRB/s390x/os
curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-Official
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official
wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official
mv RPM-GPG-KEY-CentOS-Official /etc/pki/rpm-gpg/.
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
yum install -y mariadb-devel mariadb-server mariadb-connector-c-devel
pip3 install bcrypt==4.0.1 keystone==${PACKAGE_VERSION} python-openstackclient mysqlclient
echo "Configuration and Installation started"
echo "Starting MySQL Server"
/usr/bin/mysql_install_db --user=mysql
sleep 30s
nohup mysqld_safe &>/dev/null &
sleep 60s
mysql -e "CREATE DATABASE keystone"
mysql -e "CREATE USER 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_DBPASS}'"
mysql -e "CREATE USER 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_DBPASS}'"
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%'"
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost'"
echo "Keystone install completed successfully."
echo "Starting Keystone configure"
mkdir -p /etc/keystone/
cd /etc/keystone/
wget -O keystone.conf https://docs.openstack.org/keystone/2024.2/_static/keystone.conf.sample
export OS_KEYSTONE_CONFIG_DIR=/etc/keystone
echo "Keystone configuration completed successfully"
sed -i "s|#connection = <None>|connection = mysql://keystone:${KEYSTONE_DBPASS}@localhost/keystone|g" /etc/keystone/keystone.conf
sed -i "s|#provider = fernet|provider = fernet|g" /etc/keystone/keystone.conf
env PATH=$PATH keystone-manage db_sync
echo "Initializing fernet key repo & Bootstrapping identity service"
groupadd keystone
useradd -m -g keystone keystone
mkdir -p /etc/keystone/fernet-keys
chown -R keystone:keystone /etc/keystone/fernet-keys
env PATH=$PATH keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
env PATH=$PATH keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
env PATH=$PATH keystone-manage bootstrap \
    --bootstrap-password ADMIN_PASS \
    --bootstrap-admin-url http://${KEYSTONE_HOST_IP}:35357/v3/ \
    --bootstrap-internal-url http://${KEYSTONE_HOST_IP}:5000/v3/ \
    --bootstrap-public-url http://${KEYSTONE_HOST_IP}:5000/v3/ \
    --bootstrap-region-id RegionOne
echo "ServerName ${KEYSTONE_HOST_IP}" | tee -a /etc/httpd/conf/httpd.conf
echo 'Include /etc/httpd/sites-enabled/' | tee -a /etc/httpd/conf/httpd.conf
echo 'LoadModule wsgi_module /usr/local/lib64/python3.9/site-packages/mod_wsgi/server/mod_wsgi-py39.cpython-39-s390x-linux-gnu.so' | tee -a /etc/httpd/conf/httpd.conf
mkdir -p /etc/httpd/sites-available
mkdir -p /etc/httpd/sites-enabled
curl -SL -k -o wsgi-keystone.conf $CONF_URL/rhel-wsgi-keystone.conf
mv wsgi-keystone.conf /etc/httpd/sites-available/
ln -s /etc/httpd/sites-available/wsgi-keystone.conf /etc/httpd/sites-enabled
nohup /usr/sbin/httpd &>/dev/null &
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://${KEYSTONE_HOST_IP}:5000/v3
export OS_IDENTITY_API_VERSION=3
ln -s /usr/local/bin/keystone-wsgi-admin /bin/
ln -s /usr/local/bin/keystone-wsgi-public /bin/
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://${KEYSTONE_HOST_IP}:5000/v3
export OS_IDENTITY_API_VERSION=3
if openstack service list && openstack token issue; then
	echo "------------------$PACKAGE_NAME:Verification Completed-------------------------"
    echo "$PACKAGE_VERSION $PACKAGE_NAME"
    echo "Verification"
    echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass | Verification_Completed"
else
    echo "------------------$PACKAGE_NAME:Verification Failed-------------------------"
    echo "$PACKAGE_VERSION $PACKAGE_NAME"
    echo "Verification"
    echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub  | Fail | Verification_Failed"
    exit 1
fi
