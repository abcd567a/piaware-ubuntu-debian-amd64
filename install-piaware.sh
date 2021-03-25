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

echo -e "\e[32mBuilding & Installing tcl-tls from source code. \e[39m"
echo -e "\e[32mInstalling tcl-tls dependencies \e[39m"
sudo apt install -y libssl-dev
sudo apt install -y tcl-dev
sudo apt install -y chrpath

echo -e "\e[32mCloning tcl-tls source code \e[39m"

cd  ${INSTALL_DIRECTORY}
git clone https://github.com/flightaware/tcltls-rebuild 
cd  ${INSTALL_DIRECTORY}/tcltls-rebuild
git fetch --all
git reset --hard origin/dev
echo -e "\e[32mbuilding tcl-tls package \e[39m"
./prepare-build.sh buster
cd package-buster
sudo dpkg-buildpackage -b --no-sign
echo -e "\e[32mInstalling tcl-tls package \e[39m"
cd ../
sudo dpkg -i tcl-tls_*.deb

echo -e "\e[32mInstalling piaware dependencies \e[39m"
sudo apt install -y python3-dev
sudo apt install -y python3-venv 
sudo apt install -y libboost-system-dev
sudo apt install -y libboost-program-options-dev
sudo apt install -y libboost-regex-dev
sudo apt install -y libboost-filesystem-dev
sudo apt install -y net-tools
sudo apt install -y tclx8.4
sudo apt install -y tcllib
sudo apt install -y itcl3

echo -e "\e[32mCloning piaware source code and building package \e[39m"
cd ${INSTALL_DIRECTORY}
git clone http://github.com/flightaware/piaware_builder
cd ${INSTALL_DIRECTORY}/piaware_builder
git fetch --all
git reset --hard origin/master
VER=$(git describe --tags | sed 's/^v//')
echo -e "\e[32mBuilding the piaware package \e[39m"
sudo ./sensible-build.sh buster
cd ${INSTALL_DIRECTORY}/piaware_builder/package-buster

if [[ `lsb_release -sc` == "kali-rolling" ]]; then
sudo sed -i 's/dh-systemd,//' debian/control
fi

sudo dpkg-buildpackage -b --no-sign 

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

