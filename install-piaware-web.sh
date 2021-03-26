#!/bin/bash

INSTALL_DIRECTORY=${PWD}

echo -e "\e[32mUpdating\e[39m"
sudo apt update
echo -e "\e[32mInstalling build tools\e[39m"
sudo apt install -y git
sudo apt install -y debhelper
sudo apt install -y dh-systemd

echo -e "\e[32mCloning piaware-web source code \e[39m"
cd  ${INSTALL_DIRECTORY}
git clone https://github.com/flightaware/piaware-web 
cd  ${INSTALL_DIRECTORY}/piaware-web
git fetch --all
git reset --hard origin/master
VER=$(git describe --tags | sed 's/^v//')
echo -e "\e[32mbuilding piaware-web package \e[39m"
if [[ `lsb_release -sc` == "kali-rolling" ]]; then
sudo sed -i 's/dh-systemd,//' debian/control
fi
sudo dpkg-buildpackage -b --no-sign
echo -e "\e[32mInstalling piaware-web package \e[39m"
cd ../
sudo dpkg -i piaware-web_${VER}_all.deb
sudo service lighttpd force-reload
echo ""
echo -e "\e[32mPIAWARE-WEB INSTALLATION COMPLETED \e[39m"
echo ""
echo -e "\e[32mIn your browser, go to web interface at\e[39m"
echo -e "\e[39m     $(ip route | grep -m1 -o -P 'src \K[0-9,.]*') \e[39m"
echo -e "\e[32m     OR\e[39m"
echo -e "\e[39m     $(ip route | grep -m1 -o -P 'src \K[0-9,.]*'):80 \e[39m"
echo ""
