#!/bin/bash

# TP-LINK (RTL8188EU) WIRELESS ADAPTER INSTALL
# sudo su

# Install tools
while true; do
    read -p "Do you wish to install this tools? [y/n]: " yn
    case $yn in
        [Yy]* ) make install;
				yes Y | apt-get install network-manager
				yes Y | apt-get install net-tools
				yes Y | apt-get install wireless-tools
				yes Y | apt-get install wpasupplicant
				break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes (Y/y) or no (N/n).";;
    esac
done

# Compiling & Building drivers
while true; do
    read -p "Do you wish to get & install RTL8188EU drivers? [y/n]: " yn
    case $yn in
        [Yy]* ) make install;
				echo "Compiling & Building drivers ..."
				mkdir -p /tmp/wireless-drivers && cd /tmp/wireless-drivers
				git clone https://github.com/lwfinger/rtl8188eu.git
				cd rtl8188eu && make all && make install
				break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no (Y/y) or no (N/n).";;
    esac
done

# Connect to Wi-Fi Network With WPA_Supplicant
echo 'Setup network config...'
nmcli device

read -p 'Name of Your Ethernet DEVICE [none]: ' ethinterface
ethinterface=${ethinterface:-none}

read -p 'Name of Your Wireless DEVICE [none]: ' wlinterface
wlinterface=${wlinterface:-none}

read -p 'Server static IP [192.168.0.99]: ' serverip
serverip=${serverip:-192.168.0.99}

read -p 'Gateway [192.168.0.1]: ' gateway
gateway=${gateway:-192.168.0.1}

netplan_config_dir=/etc/netplan

rm -rf $netplan_config_dir/*

# Setup Ethernet
if [[ $ethinterface != "none" ]]
    then
		ethernet_file=_netplan-ethernet.yaml
		cp 01-netplan-ethernet.yaml $ethernet_file
		sed -i "s/{ethinterface}/$ethinterface/g" $ethernet_file
		sed -i "s/{serverip}/$serverip/g" $ethernet_file
		sed -i "s/{gateway}/$gateway/g" $ethernet_file

		newfile=$netplan_config_dir/01-netplan-ethernet.yaml
		cp $ethernet_file $newfile
		rm $ethernet_file

		cat $newfile
fi

# Setup WiFi
if [[ $wlinterface != "none" ]]
    then
    	nmcli device wifi

		read -p 'Connect to ESSID: ' essid
		read -p 'Password: ' passphrase

		wifi_file=_netplan-wifi.yaml
		cp 02-netplan-wifi.yaml $wifi_file

		sed -i "s/{wlinterface}/$wlinterface/g" $wifi_file
		sed -i "s/{serverip}/$serverip/g" $wifi_file
		sed -i "s/{gateway}/$gateway/g" $wifi_file
		sed -i "s/{essid}/$essid/g" $wifi_file
		sed -i "s/{passphrase}/$passphrase/g" $wifi_file

		newfile=$netplan_config_dir/02-netplan-wifi.yaml
		cp $wifi_file $newfile
		rm $wifi_file

		cat $newfile
fi

netplan generate
netplan apply

echo 'Done!'