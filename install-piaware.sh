#!/bin/bash

INSTALL_DIRECTORY=${PWD}

echo -e "\e[32mUpdating\e[39m"
sudo apt update

## Detect OS Version
OS_VERSION=`lsb_release -sc`
echo -e "\e[35mDETECTED OS VERSION" ${OS_VERSION} "\e[39m"

## UBUNTU
if [[ ${OS_VERSION} == bionic ]]; then
  OS_VERSION=stretch
elif [[ ${OS_VERSION} == focal ]]; then
  OS_VERSION=buster
elif [[ ${OS_VERSION} == jammy ]]; then
  OS_VERSION=bullseye
elif [[ ${OS_VERSION} == bookworm ]]; then
  OS_VERSION=bullseye

## LINUX MINT
elif [[ ${OS_VERSION} == tara || ${OS_VERSION} == tessa || ${OS_VERSION} == tina || ${OS_VERSION} == tricia ]]; then
  OS_VERSION=stretch
elif [[ ${OS_VERSION} == una || ${OS_VERSION} == uma || ${OS_VERSION} == ulyana || ${OS_VERSION} == ulyssa ]]; then
  OS_VERSION=buster
elif [[ ${OS_VERSION} == vanessa || ${OS_VERSION} == vera ]]; then
  OS_VERSION=bullseye

else
  OS_VERSION=bullseye
fi

echo -e "\e[36mBUILDING PACKAGE USING DEBIAN VER" ${OS_VERSION} "\e[39m"

echo -e "\e[32mInstalling Build tools & Build dependencies\e[39m"

#Build-Tools
sudo apt install -y git
sudo apt install -y build-essential
sudo apt install -y devscripts
  
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
git reset --hard origin/master
echo -e "\e[32mbuilding tcl-tls package \e[39m"
./prepare-build.sh ${OS_VERSION}
cd package-${OS_VERSION}
sudo dpkg-buildpackage -b --no-sign
echo -e "\e[32mInstalling tcl-tls package \e[39m"
cd ../
sudo dpkg -i tcl-tls_*.deb

echo -e "\e[32mInstalling piaware dependencies \e[39m"

#Depends:
sudo apt install -y net-tools
sudo apt install -y iproute2
sudo apt install -y tclx8.4
sudo apt install -y tcl8.6
sudo apt install -y tcllib
sudo apt install -y itcl3

echo -e "\e[32mCloning piaware source code and building package \e[39m"
cd ${INSTALL_DIRECTORY}
git clone https://github.com/flightaware/piaware_builder
cd ${INSTALL_DIRECTORY}/piaware_builder
git fetch --all
git reset --hard origin/master
echo -e "\e[32mBuilding the piaware package \e[39m"
sudo ./sensible-build.sh ${OS_VERSION}
cd ${INSTALL_DIRECTORY}/piaware_builder/package-${OS_VERSION}

sudo sed -i 's/python3-dev(>=3.9)/python3-dev/' debian/control
sudo sed -i 's/tcl-tls (>= 1.7.22-2)/tcl-tls/' debian/control

sudo dpkg-buildpackage -b --no-sign 
PIAWARE_VER=$(grep "Version:" debian/piaware/DEBIAN/control | sed 's/^Version: //')

echo -e "\e[32mInstalling piaware package\e[39m"
cd ../
sudo dpkg -i piaware_${PIAWARE_VER}_*.deb

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

