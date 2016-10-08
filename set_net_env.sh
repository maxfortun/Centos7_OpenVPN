#!/bin/bash
# this script sets network interface env variables based on link name specified

link=$1
if [ -z "$link" ]; then
	echo "Usage: source ${BASH_SOURCE[0]} <id>"
	echo "Where id is one of the following:"
	ip link show|grep -o -P '(?<=^\d:\s)[^:]+'|grep -v '^lo$'
	[ "${BASH_SOURCE[0]}" != "$0" ] && return || exit
fi

inet=$(ip address show $link | grep -P '^\s*inet\s[^\s]+')
ippr=$(echo $inet|awk '{ print $2 }')

ip=${ippr%%/*}
echo "$link: ip $ip"

if [ "$ip" != "$ippr" ]; then
	prefix=${ippr##*/}
	network=$(ipcalc -n $ippr|cut -d= -f2)
else
	peerpr=$(echo $inet|awk '{ print $4 }')
	network=${peerpr%%/*}
	prefix=${peerpr##*/}
fi

echo "$link: prefix $prefix"
echo "$link: network $network"

gateway=$(ip route|grep -oP "(?<=via )[\d.]+(?= dev $link)"|sort -fu)
if [ -z "$gateway" ]; then
	gateway=$ip
fi
echo "$link: Gateway $gateway"

export ${link}_link=$link
export ${link}_ip=$ip
export ${link}_prefix=$prefix 
export ${link}_network=$network
export ${link}_gateway=$gateway
export ${link}_table=$link

