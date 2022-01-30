#!/bin/bash

INSTALL_DIRECTORY=${PWD}

echo -e "\e[32mUpdating\e[39m"
sudo apt update
echo -e "\e[32mInstalling Build tools & Build dependencies\e[39m"

#Build-Tools
sudo apt install -y git
sudo apt install -y build-essential

#Build-Depends: 
sudo apt install -y debhelper
sudo apt install -y tcl8.6-dev
sudo apt install -y autoconf
sudo apt install -y python3-dev
sudo apt install -y python3-venv
sudo apt install -y python3-setuptools
sudo apt install -y libz-dev
sudo apt install -y openssl
sudo apt install -y libboost-system-dev
sudo apt install -y libboost-program-options-dev
sudo apt install -y libboost-regex-dev
sudo apt install -y libboost-filesystem-dev
sudo apt install -y patchelf

echo -e "\e[32mInstalling piaware dependencies \e[39m"

#Depends:
sudo apt install -y net-tools
sudo apt install -y iproute2
sudo apt install -y tclx8.4
sudo apt install -y tcl8.6
sudo apt install -y tcllib
sudo apt install -y tcl-tls
sudo apt install -y itcl3

echo -e "\e[32mCloning piaware source code and building package \e[39m"
cd ${INSTALL_DIRECTORY}
git clone https://github.com/flightaware/piaware_builder
cd ${INSTALL_DIRECTORY}/piaware_builder
git fetch --all
git reset --hard origin/master
echo -e "\e[32mBuilding the piaware package \e[39m"
sudo ./sensible-build.sh bullseye
cd ${INSTALL_DIRECTORY}/piaware_builder/package-bullseye

sudo dpkg-buildpackage -b -d --no-sign 
VER=$(grep "Version:" debian/piaware/DEBIAN/control | sed 's/^Version: //')

echo -e "\e[32mInstalling piaware package\e[39m"
cd ../
sudo dpkg -i piaware_${VER}_*.deb

sudo systemctl enable piaware
sudo systemctl restart piaware

echo ""
echo -e "\e[32mPIAWARE INSTALLATION COMPLETED \e[39m"
echo ""
echo -e "\e[39mIf you already have  feeder-id, please configure piaware with it \e[39m"
echo -e "\e[39mFeeder Id is available on this address while loggedin: \e[39m"
echo -e "\e[94m    https://flightaware.com/adsb/stats/user/ \e[39m"
echo ""
echo -e "\e[39m    sudo piaware-config feeder-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \e[39m"
echo -e "\e[39m    sudo piaware-config allow-manual-updates yes \e[39m"
echo -e "\e[39m    sudo piaware-config allow-auto-updates yes \e[39m"
echo -e "\e[39m    sudo systemctl restart piaware \e[39m"
echo ""
echo -e "\e[39mIf you dont already have a feeder-id, please go to Flightaware Claim page while loggedin \e[39m"
echo -e "\e[94m    https://flightaware.com/adsb/piaware/claim \e[39m"
echo ""

