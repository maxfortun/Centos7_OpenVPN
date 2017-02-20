#!/bin/bash
wanIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
CA=$(cat ca.crt)
PUB=$(cat server.crt)
PRI=$(cat server.key)

for ovpn in *.ovpn; do
	sed "s/your-publicly-accessible-ip-here/$wanIP/g" $ovpn
	sed "s/... your ca cert here .../$CA/g" $ovpn
	sed "s/... your client public cert here .../$PUB/g" $ovpn
	sed "s/... your client private key here .../$PRI/g" $ovpn
done

