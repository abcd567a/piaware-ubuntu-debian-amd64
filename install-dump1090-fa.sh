#!/bin/bash
INSTALL_DIRECTORY=${PWD}

echo -e "\e[32mUpdating\e[39m"
sudo apt update

echo -e "\e[32mInstalling build tools\e[39m"
sudo apt install -y git
sudo apt install -y build-essential
sudo apt install -y debhelper
sudo apt install -y pkg-config
sudo apt install -y dh-systemd

echo -e "\e[32mInstalling dependencies \e[39m"
sudo apt install -y librtlsdr-dev
sudo apt install -y libncurses5-dev
sudo apt install -y lighttpd
sudo apt install -y libbladerf-dev
sudo apt install -y libhackrf-dev
sudo apt install -y liblimesuite-dev

sudo systemctl enable lighttpd
sudo systemctl restart lighttpd

echo -e "\e[32mCloning dump1090-fa source code\e[39m"
cd ${INSTALL_DIRECTORY}
git clone https://github.com/flightaware/dump1090

cd ${INSTALL_DIRECTORY}/dump1090
git fetch --all
git reset --hard origin/master

#if [[ `uname -m` == "aarch64" || `uname -m` == "armv7l" ]]; then
#    VERSION_CODENAME=`grep -oP '(?<=VERSION_CODENAME=)\w+' /etc/os-release`
#    if [[ ${VERSION_CODENAME} == "buster" ]]; then
#        echo "Using master branch"
#    elif [[ ${VERSION_CODENAME} == "bullseye" ]]; then
#        echo "Using development branch"
#        git fetch --all
#        git reset --hard origin/dev
#    fi
#fi

#if [[ `lsb_release -sc` == "kali-rolling" ]]; then
sudo sed -i 's/dh-systemd,//' debian/control
#fi

echo -e "\e[32mBuilding dump1090-fa package\e[39m"
sudo dpkg-buildpackage -b --no-sign

echo -e "\e[32mInstalling dump1090-fa \e[39m"
#VER=$(git describe --tags | sed 's/^v//')
VER=$(grep "Version:" debian/dump1090-fa/DEBIAN/control | sed 's/^Version: //')
cd ../
sudo dpkg -i dump1090-fa_${VER}_*.deb

sudo systemctl enable dump1090-fa
sudo systemctl restart dump1090-fa

echo ""
echo -e "\e[32mDUMP1090-FA INSTALLATION COMPLETED \e[39m"
echo -e "\e[31mREBOOT Computer \e[39m"
echo -e "\e[31mREBOOT Computer \e[39m"
echo -e "\e[31mREBOOT Computer \e[39m"
echo ""




