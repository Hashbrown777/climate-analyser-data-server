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
rm apache-tomcat-7.0.54.tar.gz

mkdir thredds
cd thredds
wget ftp://ftp.unidata.ucar.edu/pub/thredds/4.3/current/thredds.war
cd ..

ln -s $PWD/thredds/thredds.war tomcat/webapps/thredds.war
EOF

yum -y install git make gcc gcc-c++ pkgconfig libstdc++-devel curl curlpp curlpp-devel curl-devel libxml2 libxml2* libxml2-devel openssl-devel mailcap
yum -y remove fuse fuse* fuse-devel
 
$RUNASUSER bash <<EOF
wget "http://downloads.sourceforge.net/project/fuse/fuse-2.X/2.9.3/fuse-2.9.3.tar.gz?r=&ts=1401776172&use_mirror=ufpr"
tar -xzf fuse-2.9.3.tar.gz*
rm -f fuse-2.9.3.tar.gz*
mv fuse-2.9.3 fuse
EOF
 
cd fuse
 
$RUNASUSER bash <<EOF
./configure --prefix=/usr
make
EOF
 
make install
ldconfig
modprobe fuse
cd ..
rm -rf fuse
 
$RUNASUSER bash <<EOF
git clone https://github.com/s3fs-fuse/s3fs-fuse.git
EOF
 
cd s3fs-fuse
 
$RUNASUSER bash <<EOF
export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig/
./autogen.sh
./configure --prefix=/usr
make
EOF
 
make install
cd ..
rm -rf s3fs-fuse
 
mkdir -p $PWD/datafiles
chown $SUDO_UID:$SUDO_GID $PWD/datafiles
 
echo "user_allow_other" > /etc/fuse.conf
 
$RUNASUSER bash <<EOF
cat > mount_nectar.sh <<EOI
#!/bin/bash
/usr/bin/s3fs data $PWD/datafiles -o url="https://swift.rc.nectar.org.au:8888/" -o use_path_request_style -o allow_other -o uid=$SUDO_UID -o gid=$SUDO_GID
EOI
 
cat > unmount_nectar.sh <<EOI
#!/bin/bash
fusermount -u $PWD/datafiles
EOI
 
chmod +x mount_nectar.sh
chmod +x unmount_nectar.sh
 
./mount_nectar.sh
echo "Data storage has been mounted to '$PWD/datafiles'"
EOF

