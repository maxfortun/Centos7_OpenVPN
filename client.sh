#!/bin/bash
# Used to switch outfacing vpn client endpoint

provider=$1
id=$2
proto=$3

files=$(find /etc/openvpn/client/ -type f -path "*$provider*$id*$proto*.ovpn" -print | sort)
count=$(echo "$files" | wc -l)

echo "$files"
echo $count

if [ "$count" -ne "1" ]; then
	exit
fi

file=$files

cp "$file" /etc/openvpn/client.conf
echo -e "\n# original: $file" >> /etc/openvpn/client.conf
systemctl restart openvpn@client


