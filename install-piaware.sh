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

## DEBIAN, MX-Linux and antiX
if [[ ${OS_VERSION} == stretch ]]; then
  OS_EQV_VERSION=stretch
elif [[ ${OS_VERSION} == buster ]]; then
  OS_EQV_VERSION=buster
elif [[ ${OS_VERSION} == bullseye ]]; then
  OS_EQV_VERSION=bullseye
elif [[ ${OS_VERSION} == bookworm ]]; then
  OS_EQV_VERSION=bookworm
elif [[ ${OS_VERSION} == trixie ]]; then
  sudo bash -c "$(wget -O - https://github.com/abcd567a/temp/raw/main/install-piaware-debian13.sh)"
  exit 0


## UBUNTU
elif [[ ${OS_VERSION} == bionic ]]; then
  OS_EQV_VERSION=stretch
elif [[ ${OS_VERSION} == focal ]]; then
  OS_EQV_VERSION=buster
elif [[ ${OS_VERSION} == jammy || ${OS_VERSION} == kinetic ]]; then
  OS_EQV_VERSION=bullseye
elif [[ ${OS_VERSION} == lunar || ${OS_VERSION} == mantic ]]; then
  OS_EQV_VERSION=bookworm
elif [[ ${OS_VERSION} == noble ]]; then
  sudo bash -c "$(wget -O - https://github.com/abcd567a/temp/raw/main/install-piaware-ubuntu24.sh)"
  exit 0
  
## LINUX MINT
elif [[ ${OS_VERSION} == tara || ${OS_VERSION} == tessa || ${OS_VERSION} == tina || ${OS_VERSION} == tricia ]]; then
  OS_EQV_VERSION=stretch
elif [[ ${OS_VERSION} == una || ${OS_VERSION} == uma || ${OS_VERSION} == ulyana || ${OS_VERSION} == ulyssa ]]; then
  OS_EQV_VERSION=buster
elif [[ ${OS_VERSION} == vanessa || ${OS_VERSION} == vera || ${OS_VERSION} == victoria || ${OS_VERSION} == virginia ]]; then
  OS_EQV_VERSION=bullseye
elif [[ ${OS_VERSION} == faye ]]; then
  OS_EQV_VERSION=bookworm
elif [[ ${OS_VERSION} == wilma || ${OS_VERSION} == xia || ${OS_VERSION} == zara ]]; then
  sudo bash -c "$(wget -O - https://github.com/abcd567a/temp/raw/main/install-piaware-ubuntu24.sh)"
  exit 0
  
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
   echo -e "\e[01;31mAborting installation ...\e[39m"
   exit
fi

echo -e "\e[1;36mBUILDING PACKAGE USING DEBIAN VER" ${OS_VERSION} "\e[0;39m"

echo -e "\e[1;32mInstalling Build Tools \e[0;39m"
sleep 3
#Build-Tools
apt install -y \
git \
build-essential \
devscripts

echo -e "\e[1;32mInstalling Build dependencies \e[0;39m"
sleep 3
#Build-Depends: 
apt install -y \
debhelper \
tcl8.6-dev \
autoconf \
python3-dev \
python3-venv \
python3-setuptools \
python3-filelock \
libz-dev \
openssl \
libboost-system-dev \
libboost-program-options-dev \
libboost-regex-dev \
libboost-filesystem-dev \
patchelf

echo -e "\e[1;32mInstalling piaware dependencies \e[0;39m"
sleep 3
#Depends:
apt install -y \
net-tools \
iproute2 \
tclx8.4 \
tcl8.6 \
tcllib \
itcl3 \
rsyslog

if [[ ${OS_EQV_VERSION} == bullseye ]]; then
  apt install -y python3-pip
fi

if [[ ${OS_EQV_VERSION} == bookworm ]]; then
  apt install -y python3-wheel python3-build python3-pip
fi

if [[ ${OS_EQV_VERSION} == bookworm ]]; then
   apt install -y tcl-tls
else
echo -e "\e[1;32mBuilding & Installing tcl-tls from source code. \e[1;39m"
sleep 3
echo -e "\e[1;32mInstalling tcl-tls dependencies \e[0;39m"
sleep 3
apt install -y \
libssl-dev \
tcl-dev \
chrpath

cd  ${INSTALL_DIRECTORY}

if [[ -d tcltls-rebuild ]];
then
echo -e "\e[1;32mRenaming existing tcltls-rebuild folder by adding prefix \"old\" \e[0;39m"
mv tcltls-rebuild tcltls-rebuild-old-$RANDOM
fi

echo -e "\e[1;32mCloning tcl-tls source code \e[0;39m"
sleep 3
git clone --depth 1 https://github.com/flightaware/tcltls-rebuild
cd  ${INSTALL_DIRECTORY}/tcltls-rebuild
echo -e "\e[32mbuilding tcl-tls package \e[39m"
if [[ ${OS_EQV_VERSION} == bookworm ]]; then 
  ./prepare-build.sh bullseye
  cd package-bullseye
  dpkg-buildpackage -b --no-sign
else
  ./prepare-build.sh ${OS_EQV_VERSION}
  cd package-${OS_EQV_VERSION}
  dpkg-buildpackage -b --no-sign
fi

echo -e "\e[1;32mInstalling tcl-tls package \e[0;39m"
sleep 3
cd ../
dpkg -i tcl-tls_*.deb
apt-mark hold tcl-tls

fi

echo -e "\e[1;36mBUILDING PIAWARE PACKAGE USING DEBIAN VER" ${OS_VERSION} "\e[0;39m"
sleep 3

cd ${INSTALL_DIRECTORY}

if [[ -d piaware_builder ]];
then
echo -e "\e[32mRenaming existing piaware_builder folder by adding prefix \"old\" \e[39m"
mv piaware_builder piaware_builder-old-$RANDOM
fi

echo -e "\e[32mCloning piaware source code and building package \e[39m"
sleep 3
git clone --depth 1 https://github.com/flightaware/piaware_builder
cd ${INSTALL_DIRECTORY}/piaware_builder
echo -e "\e[1;32mBuilding the piaware package \e[0;39m"
sleep 3
./sensible-build.sh ${OS_EQV_VERSION}
cd ${INSTALL_DIRECTORY}/piaware_builder/package-${OS_EQV_VERSION}

dpkg-buildpackage -b --no-sign 
PIAWARE_VER=$(grep "Version:" debian/piaware/DEBIAN/control | sed 's/^Version: //')

echo -e "\e[1;32mInstalling piaware package\e[0;39m"
sleep 3
cd ../
dpkg -i piaware_${PIAWARE_VER}_*.deb

if [[ `ps --no-headers -o comm 1` == "systemd" ]]; then
systemctl enable piaware
systemctl restart piaware
fi

echo ""
echo -e "\e[1;32mPIAWARE INSTALLATION COMPLETED \e[0;39m"
echo ""
echo -e "\e[1;39mIf you already have  feeder-id, please configure piaware with it \e[0;39m"
echo -e "\e[1;39mFeeder Id is available on this address while loggedin: \e[0;39m"
echo -e "\e[1;94m    https://flightaware.com/adsb/stats/user/ \e[0;39m"
echo ""
echo -e "\e[39m    sudo piaware-config feeder-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \e[39m"
echo -e "\e[39m    sudo piaware-config allow-manual-updates yes \e[39m"
echo -e "\e[39m    sudo piaware-config allow-auto-updates yes \e[39m"
if [[ `ps --no-headers -o comm 1` == "systemd" ]]; then
   echo -e "\e[39m    sudo systemctl restart piaware \e[39m"
else
   echo -e "\e[39m    sudo service piaware restart \e[39m"
fi

echo ""
echo -e "\e[1;39mIf you dont already have a feeder-id, please go to Flightaware Claim page while loggedin \e[0;39m"
echo -e "\e[94m    https://flightaware.com/adsb/piaware/claim \e[39m"
echo ""

