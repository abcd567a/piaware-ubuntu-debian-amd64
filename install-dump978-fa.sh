#!/bin/bash
INSTALL_DIRECTORY=${PWD}

echo -e "\e[32mUpdating\e[39m"
sudo apt update
sudo apt install -y lsb-release

## Detect OS 
OS_ID=`lsb_release -si`
OS_RELEASE=`lsb_release -sr`
OS_VERSION=`lsb_release -sc`

echo -e "\e[35mDETECTED OS VERSION" ${OS_ID} ${OS_RELEASE} ${OS_VERSION}  "\e[39m"

## DEBIAN
if [[ ${OS_VERSION} == stretch ]]; then
  OS_VERSION=stretch
elif [[ ${OS_VERSION} == buster ]]; then
  OS_VERSION=buster
elif [[ ${OS_VERSION} == bullseye ]]; then
  OS_VERSION=bullseye
elif [[ ${OS_VERSION} == bookworm ]]; then
  OS_VERSION=bullseye

## UBUNTU
elif [[ ${OS_VERSION} == bionic ]]; then
  OS_VERSION=stretch
elif [[ ${OS_VERSION} == focal ]]; then
  OS_VERSION=buster
elif [[ ${OS_VERSION} == jammy ]]; then
  OS_VERSION=bullseye
elif [[ ${OS_VERSION} == kinetic ]]; then
  OS_VERSION=bullseye
elif [[ ${OS_VERSION} == lunar ]]; then
  OS_VERSION=bullseye
  
## LINUX MINT
elif [[ ${OS_VERSION} == tara || ${OS_VERSION} == tessa || ${OS_VERSION} == tina || ${OS_VERSION} == tricia ]]; then
  OS_VERSION=stretch
elif [[ ${OS_VERSION} == una || ${OS_VERSION} == uma || ${OS_VERSION} == ulyana || ${OS_VERSION} == ulyssa ]]; then
  OS_VERSION=buster
elif [[ ${OS_VERSION} == vanessa || ${OS_VERSION} == vera ]]; then
  OS_VERSION=bullseye

## KALI LINUX
elif [[ ${OS_ID} == Kali && ${OS_RELEASE%.*} == 2021 ]]; then
  OS_VERSION=buster
elif [[ ${OS_ID} == Kali && ${OS_RELEASE%.*} == 2022 ]]; then
  OS_VERSION=bullseye
elif [[ ${OS_ID} == Kali && ${OS_RELEASE%.*} == 2023 ]]; then
  OS_VERSION=bullseye

else
#  OS_VERSION=bullseye
   echo -e "\e[01;31mdont know how to install on" ${OS_ID} ${OS_RELEASE} ${OS_VERSION} "\e[39m"
   exit
fi

echo -e "\e[36mBUILDING PACKAGE USING DEBIAN VER" ${OS_VERSION} "\e[39m"

echo -e "\e[32mInstalling Build tools and Build dependencies\e[39m"

##Build-Tools:
sudo apt install -y git
sudo apt install -y build-essential
sudo apt install -y devscripts

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
sudo apt install -y lighttpd
#sudo apt install -y skyaware978

echo -e "\e[32mCloning dump978-fa source code\e[39m"

cd ${INSTALL_DIRECTORY}
sudo mv dump978 dump978-old-$RANDOM
git clone https://github.com/flightaware/dump978

cd ${INSTALL_DIRECTORY}/dump978
git fetch --all
git reset --hard origin/master

echo -e "\e[32mBuilding dump978-fa package\e[39m"
sudo ./prepare-build.sh ${OS_VERSION}
cd ${INSTALL_DIRECTORY}/dump978/package-${OS_VERSION}

sudo dpkg-buildpackage -b --no-sign
DUMP_VER=$(grep "Version:" debian/dump978-fa/DEBIAN/control | sed 's/^Version: //')
echo -e "\e[32mInstalling dump978-fa and SkyAware978 \e[39m"
cd ../

sudo dpkg -i skyaware978_${DUMP_VER}_*.deb
sudo systemctl enable skyaware978
sudo systemctl restart skyaware978

sudo dpkg -i dump978-fa_${DUMP_VER}_*.deb
sudo systemctl enable dump978-fa
sudo systemctl restart dump978-fa

sudo piaware-config uat-receiver-type sdr
sudo systemctl restart piaware

echo ""
echo -e "\e[32mDUMP978-FA INSTALLATION COMPLETED \e[39m"
echo -e "\e[31mSerialize 1090 and 978 dongles, and configure the\e[39m"
echo -e "\e[31mdump1090-fa, dump978-fa, and piaware accordingly \e[39m"
echo ""
