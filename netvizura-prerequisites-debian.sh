#! /bin/sh

#
# NetVizura Debian 9 and 10
# Compatible with NetVizura 4.7.x or higher
#
CODENAME=$(lsb_release -cs)

# sudo is essential
apt-get update --allow-releaseinfo-change
apt-get install lsb-release wget sudo dirmngr software-properties-common fontconfig -y

# 3rd-party PostgreSQL PGDG repository
if [ ! -f /etc/apt/sources.list.d/pgdg.list ]
then
        echo "deb http://apt.postgresql.org/pub/repos/apt/ $CODENAME-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
        wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
fi


# Update APT package lists
sudo apt-get update
if [ "$CODENAME" = "buster" ] || [ "$CODENAME" = "bullseye" ]
then
# Install prerequisites
#Java adoptopenjdk installation
wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
sudo add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
sudo apt-get update && sudo apt-get install adoptopenjdk-8-hotspot -y
#prevent java 11 from installing 
sudo apt-mark hold openjdk-*
sudo apt-get -y install tomcat9
sed -i '/JAVA_HOME/d' /etc/default/tomcat9
echo "JAVA_HOME=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64" >> /etc/default/tomcat9
systemctl restart tomcat9

elif [ "$CODENAME" = "stretch" ]
then
sudo apt-get -y install openjdk-8-jdk-headless
sudo sed -i -e '/^assistive_technologies=/s/^/#/' /etc/java-*-openjdk/accessibility.properties
sudo apt-get -y install tomcat8
else
echo "This Debian version is not supported"
exit 1
fi

sudo apt-get -y install postgresql postgresql-client
sed -i '/^host/ s/scram-sha-256/trust/' /etc/postgresql/14/main/pg_hba.conf
systemctl restart postgresql

if [ "$CODENAME" = "buster" ] || [ "$CODENAME" = "bullseye" ]
then
#setting tomcat write permissions to netvizura folders
if [ ! -f /etc/systemd/system/tomcat9.service.d/logging-allow.conf ]; then
sudo mkdir -p /etc/systemd/system/tomcat9.service.d
echo -e "[Service]\nReadWritePaths=/var/lib/netvizura\nReadWritePaths=/etc/.netvizura" | sudo tee /etc/systemd/system/tomcat9.service.d/logging-allow.conf
mkdir -p /etc/.netvizura
chown tomcat /etc/.netvizura
mkdir -p /var/lib/netvizura
chown tomcat /var/lib/netvizura
sudo systemctl daemon-reload
sudo systemctl restart tomcat9
fi
fi
