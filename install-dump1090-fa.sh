#!/bin/bash
INSTALL_DIRECTORY=${PWD}

echo -e "\e[32mUpdating\e[39m"
sudo apt update

echo -e "\e[32mInstalling Build tools and Build dependencies\e[39m"

##Build-Tools
sudo apt install -y git
sudo apt install -y build-essential

##Build-Depends:
sudo apt install -y debhelper
sudo apt install -y librtlsdr-dev
sudo apt install -y libbladerf-dev
sudo apt install -y libhackrf-dev
sudo apt install -y liblimesuite-dev
sudo apt install -y libusb-1.0-0-dev
sudo apt install -y pkg-config
sudo apt install -y libncurses5-dev

echo -e "\e[32mInstalling dependencies \e[39m"

##Depends:
sudo apt install -y adduser
sudo apt install -y lighttpd
sudo systemctl enable lighttpd
sudo systemctl restart lighttpd

echo -e "\e[32mCloning dump1090-fa source code\e[39m"
cd ${INSTALL_DIRECTORY}
git clone https://github.com/flightaware/dump1090

cd ${INSTALL_DIRECTORY}/dump1090
git fetch --all
git reset --hard origin/master

echo -e "\e[32mBuilding dump1090-fa package\e[39m"
sudo ./prepare-build.sh bullseye
cd ${INSTALL_DIRECTORY}/dump1090/package-bullseye

sudo dpkg-buildpackage -b --no-sign
VER=$(grep "Version:" debian/dump1090-fa/DEBIAN/control | sed 's/^Version: //')

echo -e "\e[32mInstalling dump1090-fa\e[39m"
cd ../
sudo dpkg -i dump1090-fa_${VER}_*.deb

sudo systemctl enable dump1090-fa
sudo systemctl restart dump1090-fa

echo ""
echo -e "\e[32mDUMP1090-FA~DEV INSTALLATION COMPLETED \e[39m"
echo -e "\e[31mREBOOT Computer \e[39m"
echo -e "\e[31mREBOOT Computer \e[39m"
echo -e "\e[31mREBOOT Computer \e[39m"
echo ""



