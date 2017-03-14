#!/bin/bash

# https://community.openvpn.net/openvpn/wiki/BridgingAndRouting
# 

cd $(dirname $0)

debug=${debug-echo}

LOCAL_IF=$1
VPNIN_IF=$2
VPNOUT_IF=$3
if [ -z "$VPNIN_IF" ]; then
	echo "Usage to show commands: $0 <local> <vpn in> [vpn out]"
	echo "Usage to run commands: debug= $0 <local> <vpn in> [vpn out]"
	echo "Where ids are one of the following:"
	ip link show|grep -o -P '(?<=\d:\s)[^:]+'|grep -v '^lo$'
	exit
fi

. ./set_net_env.sh $LOCAL_IF
eval LOCAL_NETWORK=\$${LOCAL_IF}_network
eval LOCAL_PREFIX=\$${LOCAL_IF}_prefix

. ./set_net_env.sh $VPNIN_IF
eval VPNIN_NETWORK=\$${VPNIN_IF}_network
eval VPNIN_PREFIX=\$${VPNIN_IF}_prefix

# Allow traffic initiated from VPN to access LAN
$debug iptables	-I FORWARD \
		-i $VPNIN_IF -o $LOCAL_IF \
		-s $VPNIN_NETWORK/$VPNIN_PREFIX -d $LOCAL_NETWORK/$LOCAL_PREFIX \
		-m conntrack --ctstate NEW -j ACCEPT

if [ -z "$VPNOUT_IF" ]; then
	VPNOUT_IF=$LOCAL_IF
fi

. ./set_net_env.sh $VPNOUT_IF
eval VPNOUT_NETWORK=\$${VPNOUT_IF}_network
eval VPNOUT_PREFIX=\$${VPNOUT_IF}_prefix

# Allow traffic initiated from LAN to access "the world"
$debug iptables	-I FORWARD \
		-i $LOCAL_IF -o $VPNOUT_IF \
	 	-s $LOCAL_NETWORK/$LOCAL_PREFIX \
		-m conntrack --ctstate NEW -j ACCEPT

# Allow traffic initiated from VPN to access "the world"
$debug iptables	-I FORWARD \
		-i $VPNIN_IF -o $VPNOUT_IF \
		-s $VPNIN_NETWORK/$VPNIN_PREFIX \
		-m conntrack --ctstate NEW -j ACCEPT

# Masquerade traffic from VPN to "the world" -- done in the nat table
$debug iptables	-t nat -I POSTROUTING -o $VPNOUT_IF \
	  	-s $VPNIN_NETWORK/$VPNIN_PREFIX -j MASQUERADE

# Masquerade traffic from LAN to "the world"
$debug iptables	-t nat -I POSTROUTING -o $VPNOUT_IF \
	  	-s $LOCAL_NETWORK/$LOCAL_PREFIX -j MASQUERADE

# Allow established traffic to pass back and forth
$debug iptables	-I FORWARD \
		-m conntrack --ctstate RELATED,ESTABLISHED \
	 	-j ACCEPT



