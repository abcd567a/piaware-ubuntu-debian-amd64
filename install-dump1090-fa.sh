#!/bin/bash

echo -e "\e[32mUpdating\e[39m"
apt update

set -e
trap 'echo "[ERROR] Error in line $LINENO when executing: $BASH_COMMAND"' ERR

INSTALL_DIRECTORY=${PWD}

apt install -y lsb-release

## Detect OS
OS_ID=`lsb_release -si`
OS_RELEASE=`lsb_release -sr`
OS_VERSION=`lsb_release -sc`
OS_EQV_VERSION=""

echo -e "\e[35mDETECTED OS VERSION" ${OS_ID} ${OS_RELEASE} ${OS_VERSION}  "\e[39m"

# DEBIAN
if [[ ${OS_VERSION} == stretch ]]; then
  OS_EQV_VERSION=stretch
elif [[ ${OS_VERSION} == buster ]]; then
  OS_EQV_VERSION=buster
elif [[ ${OS_VERSION} == bullseye ]]; then
  OS_EQV_VERSION=bullseye
elif [[ ${OS_VERSION} == bookworm ]]; then
  OS_EQV_VERSION=bookworm
elif [[ ${OS_VERSION} == trixie ]]; then
  OS_EQV_VERSION=bookworm
  
## UBUNTU
elif [[ ${OS_VERSION} == bionic ]]; then
  OS_EQV_VERSION=stretch
elif [[ ${OS_VERSION} == focal ]]; then
  OS_EQV_VERSION=buster
elif [[ ${OS_VERSION} == jammy ]]; then
  OS_EQV_VERSION=bullseye
elif [[ ${OS_VERSION} == kinetic ]]; then
  OS_EQV_VERSION=bullseye
elif [[ ${OS_VERSION} == lunar || ${OS_VERSION} == mantic || ${OS_VERSION} == noble ]]; then
  OS_EQV_VERSION=bookworm
  
## LINUX MINT
elif [[ ${OS_VERSION} == tara || ${OS_VERSION} == tessa || ${OS_VERSION} == tina || ${OS_VERSION} == tricia ]]; then
  OS_EQV_VERSION=stretch
elif [[ ${OS_VERSION} == una || ${OS_VERSION} == uma || ${OS_VERSION} == ulyana || ${OS_VERSION} == ulyssa ]]; then
  OS_EQV_VERSION=buster
elif [[ ${OS_VERSION} == vanessa || ${OS_VERSION} == vera || ${OS_VERSION} == victoria || ${OS_VERSION} == virginia ]]; then
  OS_EQV_VERSION=bullseye
elif [[ ${OS_VERSION} == faye || ${OS_VERSION} == wilma || ${OS_VERSION} == xia ]]; then
  OS_EQV_VERSION=bookworm

## KALI LINUX
elif [[ ${OS_ID} == Kali && ${OS_RELEASE%.*} == 2021 ]]; then
  OS_EQV_VERSION=buster
elif [[ ${OS_ID} == Kali && ${OS_RELEASE%.*} == 2022 ]]; then
  OS_EQV_VERSION=bullseye
elif [[ ${OS_ID} == Kali && ${OS_RELEASE%.*} == 2023 ]]; then
  OS_EQV_VERSION=bookworm
elif [[ ${OS_ID} == Kali && ${OS_RELEASE%.*} == 2024 ]]; then
  OS_EQV_VERSION=bookworm
  
## ANY OTHER
else
   echo -e "\e[01;31mdont know how to install on" ${OS_ID} ${OS_RELEASE} ${OS_VERSION} "\e[39m"
   exit
fi

echo -e "\e[36mBUILDING PACKAGE USING DEBIAN VER" ${OS_EQV_VERSION} "\e[39m"

echo -e "\e[32mInstalling Build tools and Build dependencies\e[39m"

##Build-Tools
apt install -y \
git \
build-essential \
devscripts

##Build-Depends:
apt install -y \
debhelper \
librtlsdr-dev \
libbladerf-dev \
libhackrf-dev \
liblimesuite-dev \
libusb-1.0-0-dev \
pkg-config \
libncurses5-dev \
libsoapysdr-dev

echo -e "\e[32mInstalling dependencies \e[39m"

##Depends:
apt install -y adduser
apt install -y lighttpd

if [[ ${OS_ID} == Kali ]];
then
systemctl enable lighttpd
systemctl restart lighttpd
fi

cd ${INSTALL_DIRECTORY}

if [[ -d dump1090 ]];
then
echo -e "\e[32mRenaming existing dump1090 folder by adding prefix \"old\" \e[39m"
mv dump1090 dump1090-old-$RANDOM
fi

echo -e "\e[32mCloning dump1090-fa source code\e[39m"
git clone --depth 1 https://github.com/flightaware/dump1090

cd ${INSTALL_DIRECTORY}/dump1090

echo -e "\e[32mBuilding dump1090-fa package\e[39m"
./prepare-build.sh ${OS_EQV_VERSION}
cd ${INSTALL_DIRECTORY}/dump1090/package-${OS_EQV_VERSION}

dpkg-buildpackage -b --no-sign
DUMP_VER=$(grep "Version:" debian/dump1090-fa/DEBIAN/control | sed 's/^Version: //')

echo -e "\e[32mInstalling dump1090-fa\e[39m"
cd ../
dpkg -i dump1090-fa_${DUMP_VER}_*.deb

wget -O /etc/udev/rules.d/rtl-sdr.rules https://github.com/abcd567a/temp/raw/main/rtl-sdr.rules

if [[ `ps --no-headers -o comm 1` == "systemd" ]]; then
   systemctl enable dump1090-fa
   systemctl restart dump1090-fa

else
   echo -e "\e[32mFOR MX LINUX and other OS using SysVinit instead of Systemd,\e[39m"
   echo -e "\e[32minstalling SysVinit for dump1090-fa\e[39m"
   wget -O /etc/init.d/dump1090-fa https://github.com/abcd567a/dump1090-fa-init.d/raw/main/dump1090-fa
   sudo chmod +x /etc/init.d/dump1090-fa
   update-rc.d dump1090-fa defaults
   /etc/init.d/dump1090-fa start
fi

echo ""
echo -e "\e[32mDUMP1090-FA INSTALLATION COMPLETED \e[39m"
echo -e "\e[31mREBOOT Computer \e[39m"
echo -e "\e[31mREBOOT Computer \e[39m"
echo -e "\e[31mREBOOT Computer \e[39m"
echo ""



