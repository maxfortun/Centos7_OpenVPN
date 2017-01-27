#!/bin/bash

# https://www.digitalocean.com/community/tutorials/how-to-setup-and-configure-an-openvpn-server-on-centos-7

yum -y install epel-release
yum -y install openvpn easy-rsa 
yum -y install policycoreutils-python
yum -y install iptables-services 

systemctl mask firewalld
systemctl enable iptables
systemctl stop firewalld
systemctl start iptables
iptables --flush

cp server*.conf /etc/openvpn

mkdir -p /etc/openvpn/easy-rsa/keys
cp -rf /usr/share/easy-rsa/2.0/* /etc/openvpn/easy-rsa
cp /etc/openvpn/easy-rsa/openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf
cd /etc/openvpn/easy-rsa
sed -i 's/\(KEY_NAME="\)[^"]*"/KEY_NAME="server"/g' vars
source ./vars
./clean-all
./build-ca
./build-key-server server
./build-dh
cd /etc/openvpn/easy-rsa/keys
cp dh2048.pem ca.crt server.crt server.key /etc/openvpn

cd /etc/openvpn/easy-rsa
./build-key client

cat <<_EOT_ >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
_EOT_

systemctl restart network.service

systemctl -f enable openvpn@serverudp.service
systemctl -f enable openvpn@servertcp.service

systemctl start openvpn@serverudp.service
systemctl start openvpn@servertcp.service

