#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
 
RUNASUSER="sudo -u $SUDO_USER"
 
yum -y install java-1.7.0-openjdk java-1.7.0-openjdk-devel

$RUNASUSER bash <<EOF
wget http://apache.mirror.serversaustralia.com.au/tomcat/tomcat-7/v7.0.54/bin/apache-tomcat-7.0.54.tar.gz
tar -xzf apache-tomcat-7.0.54.tar.gz
mv apache-tomcat-7.0.54 tomcat

mkdir thredds
cd thredds
wget ftp://ftp.unidata.ucar.edu/pub/thredds/4.3/current/thredds.war
cd ..

ln -s $PWD/thredds/thredds.war tomcat/webapps/thredds.war
EOF

