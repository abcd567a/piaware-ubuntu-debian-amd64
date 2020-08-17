#!/bin/bash
INSTALL_DIRECTORY=${PWD}

echo -e "\e[32mUpdating\e[39m"
sudo apt update
echo -e "\e[32mInstalling build tools\e[39m"
sudo apt install -y git dh-systemd devscripts pkg-config

echo -e "\e[32mInstalling dependencies \e[39m"
sudo apt install -y lighttpd librtlsdr-dev libusb-1.0-0-dev libncurses5-dev

echo -e "\e[32mCloning dump1090-fa source code\e[39m"

cd ${INSTALL_DIRECTORY}
git clone https://github.com/flightaware/dump1090

echo -e "\e[32mWorkaround for non-available package libbladerf1\e[39m"
echo -e "\e[32mThe package libbladerf1 is missing from package libbladerf-dev in Ubuntu 20 repository\e[39m"

cd ${INSTALL_DIRECTORY}/dump1090
sudo sed -i 's/BLADERF=yes/BLADERF=no/' debian/rules
sudo sed -i  's/, libbladerf-dev//' debian/control
sudo sed -i 's/libbladerf1 (>= 0.2016.06), //' debian/control

echo -e "\e[32mBuilding dump1090-fa package\e[39m"
sudo dpkg-buildpackage -b --no-sign


echo -e "\e[32mInstalling dump1090-fa \e[39m"
cd ../  
sudo dpkg -i dump1090-fa_3.8.1*.deb

echo -e "\e[32mEnabling dump1090-fa (for Kali Linux)\e[39m"
sudo systemctl enable dump1090-fa
sudo systemctl restart dump1090-fa

echo ""
echo -e "\e[32mDUMP1090-FA INSTALLATION COMPLETED \e[39m"
echo ""
echo -e "\e[32mCheck status by following command: \e[39m"
echo ""
echo -e "\e[33m    sudo systemctl status dump1090-fa  \e[39m"
echo ""
echo -e "\e[31mIf status shows:\e[39m" "\e[33mFailed with result 'exit-code'\e[39m""\e[31m, then REBOOT Computer \e[39m"
echo ""
