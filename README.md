### <ins>OPTION-1</ins>: </br>Install Pre-built Packages (ver 9) amd64, x86_64, arm64, armhf of piaware, dump1090-fa, dump978-fa On: </br> [Ubuntu 20](https://github.com/abcd567a/ubuntu20/blob/master/README.md) &nbsp; &nbsp; [Ubuntu 22](https://github.com/abcd567a/ubuntu22/blob/master/README.md) &nbsp; &nbsp; [Ubuntu 24](https://github.com/abcd567a/ubuntu24/blob/master/README.md) </br> [Debian 11](https://github.com/abcd567a/debian11/blob/master/README.md) &nbsp; &nbsp; &nbsp; [Debian 12](https://github.com/abcd567a/debian12/blob/master/README.md) &nbsp; &nbsp; &nbsp; [Debian 13](https://github.com/abcd567a/debian13/blob/master/README.md)
### <ins>OPTION-2</ins>: </br>Build & Install Packages Right On Your Computer / Pi, Using Source Code, <ins>By Automated Scripts</ins> Given Below:</br> These Scripts Build the <ins>_latest version_</ins> of piaware, dump1090-fa, piaware-web, and dump978-fa, on following OS: </br>

### (a) Ubuntu 18, 20, 22, 23 & 24 - amd64 / x86_64  
### (b) Debian 9, 10, 11, 12 & 13 - amd64 / x86_64  
### (c) Linux Mint 19, 20, 21 & 22 - amd64 / x86_64  
### (d) Kali-linux 2021, 2022, 2023 & 2024 - amd64  
### (e) On RPI Model 3 & 4 (32-bit & 64-bit / armv7l & aarch64) Raspberry Pi OS Stretch, Buster, Bullseye & Bookworm, DietPi OS Stretch, Buster, Bullseye, & Bookworm, Orange Pi Armbian OS Buster  Bullseye, Bookworm, Jammy, Ubuntu 18, 20, 22, and 24 for RPi, and Kali 2021, 2022, 2023, & 2024 for RPi 
### (f) On RPI <ins>Model 5</ins> Raspberry Pi OS Bookworm (32-bit & 64-bit) </br></br>

## (1) <ins>Install DUMP1090-FA</ins>

Copy-paste following command in SSH console and press Enter key. The script will install dump1090-fa. </br></br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/piaware-ubuntu-debian-amd64/master/install-dump1090-fa.sh)" `</br></br>


## (2) <ins>Install PIAWARE</ins> 
Copy-paste following command in SSH console and press Enter key. The script will install piaware. </br></br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/piaware-ubuntu-debian-amd64/master/install-piaware.sh)" `</br></br>

## (3) <ins>Install PIAWARE-WEB</ins>
Copy-paste following command in SSH console and press Enter key. The script will install piaware-web. </br></br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/piaware-ubuntu-debian-amd64/master/install-piaware-web.sh)" `</br></br>


## (4) <ins>Install DUMP978-FA</ins> (For USA ONLY. Requires 2nd Dongle)
If you want to receive both ES1090 and UAT978, then two dongles are required, one for 1090 MHz and other for 978 MHz. </br>
### (4.1) Copy-paste following command in SSH console and press Enter key. The script will install dump978-fa and skyaware978: </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/piaware-ubuntu-debian-amd64/master/install-dump978-fa.sh)" `</br></br>

### (4.2) Serialize dongles as follows </br>
If you want to receive both ES1090 and UAT978, then two dongles are required, one for 1090 MHz and other for 978 MHz. In this case you will have to serialize dongles so that correct dongle+antenna sets are used by dump1090-fa and dump978-fa. </br></br>

For 1090 Mhz dongle: use serial # 00001090 </br>
For 978 Mhz dongle : use serial # 00000978 </br></br>


(4.1.1) Issue following command to install serialization software: </br>
`sudo apt install rtl-sdr` </br></br>
**(4.1.2) Unplug ALL DVB-T dongles from RPi** </br></br>
(4.1.3) Plugin only that DVB-T dongle which you want to use for dump1090-fa. All other dongles should be unplugged. </br></br>
(4.1.4) Issue following command. Say yes when asked for confirmation to chang serial number. </br>
`rtl_eeprom -s 00001090` </br></br>
**(4.1.5) Unplug 1090 dongle** </br></br>
(4.1.6) Plugin only that DVB-T dongle which you want to use for dump978-fa. All other dongles should be unplugged. </br></br>
(4.1.7) Issue following command. Say yes when asked for confirmation to chang serial number. </br>
`rtl_eeprom -s 00000978` </br></br>
**(4.1.8) Unplug 978 dongle** </br></br>
**IMPORTANT:** After completing above commands, unplug and then replug both dongles. </br>

### (4.3) - Configure dump1090-fa & dump978-fa to use dongles of assigned serial numbers </br>
```
sudo sed -i 's/^RECEIVER_SERIAL=.*/RECEIVER_SERIAL=00001090/' /etc/default/dump1090-fa  
sudo sed -i 's/driver=rtlsdr[^ ]* /driver=rtlsdr,serial=00000978 /' /etc/default/dump978-fa  
```

### (4.4) - Reboot so that dump1090-fa & dump978-fa can pick their assigned dongles at boot </br>

`sudo reboot `   </br>



