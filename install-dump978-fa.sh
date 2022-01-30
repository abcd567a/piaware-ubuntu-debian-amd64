#!/bin/bash
INSTALL_DIRECTORY=${PWD}

echo -e "\e[32mUpdating\e[39m"
sudo apt update

echo -e "\e[32mInstalling Build tools and Build dependencies\e[39m"

##Build-Tools:
sudo apt install -y git
sudo apt install -y build-essential

##Build-Depends:
sudo apt install -y debhelper
sudo apt install -y libboost-system-dev
sudo apt install -y libboost-program-options-dev
sudo apt install -y libboost-regex-dev
sudo apt install -y libboost-filesystem-dev
sudo apt install -y libsoapysdr-dev

echo -e "\e[32mInstalling dependencies \e[39m"

##Depends:
sudo apt install -y adduser
sudo apt install -y soapysdr-module-rtlsdr
sudo apt install -y skyaware978

echo -e "\e[32mCloning dump978-fa source code\e[39m"

cd ${INSTALL_DIRECTORY}
git clone https://github.com/flightaware/dump978

cd ${INSTALL_DIRECTORY}/dump978
git fetch --all
git reset --hard origin/master

echo -e "\e[32mBuilding dump978-fa package\e[39m"
sudo ./prepare-build.sh bullseye
cd ${INSTALL_DIRECTORY}/dump978/package-bullseye

sudo dpkg-buildpackage -b --no-sign
VER=$(grep "Version:" debian/dump978-fa/DEBIAN/control | sed 's/^Version: //')
echo -e "\e[32mInstalling dump978-fa and SkyAware978 \e[39m"
cd ../
sudo dpkg -i dump978-fa_${VER}_*.deb
sudo systemctl enable dump978-fa
sudo systemctl restart dump978-fa

sudo dpkg -i skyaware978_${VER}_*.deb
sudo systemctl enable skyaware978
sudo systemctl restart skyaware978

sudo piaware-config uat-receiver-type sdr
sudo systemctl restart piaware

echo ""
echo -e "\e[32mDUMP978-FA INSTALLATION COMPLETED \e[39m"
echo -e "\e[31mSerialize 1090 and 978 dongles, and configure the\e[39m"
echo -e "\e[31mdump1090-fa, dump978-fa, and piaware accordingly \e[39m"
echo ""
