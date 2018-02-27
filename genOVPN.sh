#!/bin/bash
wanHost="$1"
if [ -z "$wanHost" ]; then
	wanHost=$(dig +short myip.opendns.com @resolver1.opendns.com)
fi

cd /etc/openvpn

PKI=/etc/openvpn/easy-rsa/pki

CA=$(cat $PKI/ca.crt)
CA=${CA//$'\n'/\\$'\n'}
CA=${CA//$'\r'/\\$'\r'}

PUB=$(cat $PKI/issued/client.crt)
PUB=${PUB//$'\n'/\\$'\n'}
PUB=${PUB//$'\r'/\\$'\r'}

PRI=$(cat $PKI/private/client.key)
PRI=${PRI//$'\n'/\\$'\n'}
PRI=${PRI//$'\r'/\\$'\r'}

for ovpn in *.ovpn; do
	sed -i "s#your-publicly-accessible-ip-here#$wanHost#g" $ovpn
	sed -i "s#... your ca cert here ...#$CA#g" $ovpn
	sed -i "s#... your client public cert here ...#$PUB#g" $ovpn
	sed -i "s#... your client private key here ...#$PRI#g" $ovpn
done

