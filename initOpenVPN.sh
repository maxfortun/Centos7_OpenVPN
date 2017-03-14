#!/bin/bash

# https://www.digitalocean.com/community/tutorials/how-to-setup-and-configure-an-openvpn-server-on-centos-7

# CWD - current work dir
# SWD = script work dir
CWD=$(pwd)
SWD=$(dirname $0)
cd $SWD
SWD=$(pwd)
cd $CWD

yum -y install epel-release openvpn easy-rsa policycoreutils-python iptables-services bind-utils 

systemctl mask firewalld
systemctl enable iptables
systemctl stop firewalld
systemctl start iptables
iptables --flush

# May want to replace this line with something more granular
# iptables -A INPUT -p udp -m state --state NEW -m udp --dport 1194 -j ACCEPT
# iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 1194 -j ACCEPT
iptables-save > /etc/sysconfig/iptables

cp server*.conf learn-address.sh /etc/openvpn
cp openvpn.sudoers /etc/sudoers.d/openvpn
cp unpriv-ip /usr/local/sbin/unpriv-ip
./openvpn_unpriv_hack.sh

mkdir -p /etc/openvpn/easy-rsa/keys
cp -rf /usr/share/easy-rsa/2.0/* /etc/openvpn/easy-rsa
cp /etc/openvpn/easy-rsa/openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf
cd /etc/openvpn/easy-rsa
sed -i 's/\(KEY_NAME="\)[^"]*"/KEY_NAME="server"/g' vars
source ./vars

export EASY_RSA="${EASY_RSA:-.}"

./clean-all

"$EASY_RSA/pkitool" --initca --sign
"$EASY_RSA/pkitool" --server --sign server

./build-dh
cd /etc/openvpn/easy-rsa/keys
cp dh2048.pem ca.crt server.crt server.key /etc/openvpn

cd /etc/openvpn/easy-rsa
"$EASY_RSA/pkitool" --sign client

$SWD/genOVPN.sh

cat <<_EOT_ >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
_EOT_

systemctl restart network.service

chown openvpn:openvpn /var/run/openvpn/

systemctl -f enable openvpn@serverudp.service
systemctl -f enable openvpn@servertcp.service

systemctl start openvpn@serverudp.service
systemctl start openvpn@servertcp.service

cat <<_EOT_
Run set_local_routing.sh then set_iptables.sh.
Test your config to make sure it works.
If everything is ok, then save config using save_routing.sh.
_EOT_

