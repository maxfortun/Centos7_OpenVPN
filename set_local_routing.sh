#!/bin/bash
# In some configurations it is needed to explicitly route local traffic back to the requesting network interface
# Such as during the initial openvpn handshaking.
# this script needs to be executed only once.

debug=${debug-echo}

link=$1
if [ -z "$link" ]; then
	echo "Usage to show commands: $0 <id> [mark]"
	echo "Usage to run commands: debug= $0 <id> [mark]"
	echo "Where mark is optional and is a number"
	echo "Where id is one of the following:"
	ip link show|grep -o -P '(?<=\d:\s)[^:]+'|grep -v '^lo$'
	exit
fi

. ./set_net_env.sh $link

eval gateway=\$${link}_gateway

mark=${2-1}
echo "$link: mark $mark"

table=$link

$debug iptables -t mangle -A PREROUTING -m conntrack --ctstate NEW -i $link -j CONNMARK --set-mark $mark
$debug iptables -t mangle -A OUTPUT -m connmark --mark $mark -j CONNMARK --restore-mark

$debug ip route add default via $gateway table $table
$debug ip rule add fwmark $mark table $table


