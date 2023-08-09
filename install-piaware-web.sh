#!/bin/bash

set -e
trap 'echo "[ERROR] Error in line $LINENO when executing: $BASH_COMMAND"' ERR

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

echo -e "\e[32mInstalling build tools\e[39m"
sudo apt install -y git
sudo apt install -y build-essential
sudo apt install -y debhelper

cd  ${INSTALL_DIRECTORY}

if [[ -d piaware-web ]];
then
echo -e "\e[32mRenaming existing piaware-web folder by adding prefix \"old\" \e[39m"
sudo mv piaware-web piaware-web-old-$RANDOM
fi

echo -e "\e[32mCloning piaware-web source code \e[39m"
git clone https://github.com/flightaware/piaware-web
cd  ${INSTALL_DIRECTORY}/piaware-web
git fetch --all
git reset --hard origin/master

echo -e "\e[32mbuilding piaware-web package \e[39m"
sudo ./prepare-build.sh ${OS_VERSION}
cd  ${INSTALL_DIRECTORY}/piaware-web/package-${OS_VERSION}

sudo dpkg-buildpackage -b --no-sign
VER=$(grep "Version:" debian/piaware-web/DEBIAN/control | sed 's/^Version: //')

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
