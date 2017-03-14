#!/bin/bash
wanIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
CA=$(cat easy-rsa/keys/ca.crt)
CA=${CA//$'\n'/\\$'\n'}
CA=${CA//$'\r'/\\$'\r'}

PUB=$(cat easy-rsa/keys/client.crt)
PUB=${PUB//$'\n'/\\$'\n'}
PUB=${PUB//$'\r'/\\$'\r'}

PRI=$(cat easy-rsa/keys/client.key)
PRI=${PRI//$'\n'/\\$'\n'}
PRI=${PRI//$'\r'/\\$'\r'}

for ovpn in *.ovpn; do
	sed -i "s#your-publicly-accessible-ip-here#$wanIP#g" $ovpn
	sed -i "s#... your ca cert here ...#$CA#g" $ovpn
	sed -i "s#... your client public cert here ...#$PUB#g" $ovpn
	sed -i "s#... your client private key here ...#$PRI#g" $ovpn
done

