#!/bin/bash

iptables-save > /etc/sysconfig/iptables
ip link show|grep -o -P '(?<=\d:\s)[^:]+'|grep -v '^lo$' | while read link; do
	routes=$(ip route show table $link 2>/dev/null)
	if [ -n "$routes" ]; then
		echo "$routes" > /etc/sysconfig/network-scripts/route-$link
	fi

	rules=$(ip rule list 2>/dev/null | grep $link | sed 's/^[0-9]*:\s*//g')
	if [ -n "$rules" ]; then
		echo "$rules" > /etc/sysconfig/network-scripts/rule-$link
	fi
done
