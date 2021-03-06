#!/bin/bash
wanHost="$1"

# https://www.digitalocean.com/community/tutorials/how-to-setup-and-configure-an-openvpn-server-on-centos-7

# CWD - current work dir
# SWD = script work dir
CWD=$(pwd)
SWD=$(dirname $0)
cd $SWD
SWD=$(pwd)
cd $CWD

yum -y install epel-release 
yum -y install openvpn easy-rsa policycoreutils-python iptables-services traceroute net-tools NetworkManager-config-routing-rules bind bind-utils iptables initscripts

systemctl mask firewalld
systemctl enable iptables
systemctl stop firewalld
systemctl start iptables
iptables --flush

# May want to replace this line with something more granular
# iptables -A INPUT -p udp -m state --state NEW -m udp --dport 1194 -j ACCEPT
# iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 1194 -j ACCEPT
iptables-save > /etc/sysconfig/iptables

cp server*.conf client*.ovpn learn-address.sh /etc/openvpn
cp openvpn.sudoers /etc/sudoers.d/openvpn
cp unpriv-ip /usr/local/sbin/unpriv-ip
./openvpn_unpriv_hack.sh

# https://community.openvpn.net/openvpn/wiki/EasyRSA3-OpenVPN-Howto
mkdir -p /etc/openvpn/easy-rsa/keys
easyRSAVersion=$(ls -1 /usr/share/easy-rsa/|sort -V|tail -1)
cp -rf /usr/share/easy-rsa/$easyRSAVersion/* /etc/openvpn/easy-rsa
openSSLCFG=$(ls -1 /etc/openvpn/easy-rsa/openssl-*.cnf|sort -V|tail -1)
cp $openSSLCFG /etc/openvpn/easy-rsa/openssl.cnf
cd /etc/openvpn/easy-rsa
./easyrsa init-pki
./easyrsa --batch build-ca nopass
./easyrsa --batch gen-req server nopass
./easyrsa --batch sign-req server server
./easyrsa --batch gen-req client nopass
./easyrsa --batch sign-req client client
./easyrsa gen-dh

cd /etc/openvpn/easy-rsa/pki
cp dh*.pem ca.crt issued/server.crt private/server.key /etc/openvpn

cd /etc/openvpn/easy-rsa

$SWD/genOVPN.sh "$wanHost"

cat <<_EOT_ >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
_EOT_

systemctl restart network.service

sed -i 's/ root / openvpn /g' /usr/lib/tmpfiles.d/openvpn.conf
chown openvpn:openvpn /var/run/openvpn/

systemctl -f enable openvpn@serverudp.service
systemctl -f enable openvpn@servertcp.service

systemctl start openvpn@serverudp.service
systemctl start openvpn@servertcp.service

sed -i 's#listen-on port 53.*$#listen-on port 53 { 127.0.0.1; 10.8.1.1; };#g' /etc/named.conf
sed -i 's#allow-query .*$#allow-query { localhost; 10.8.1.0/24; };#g' /etc/named.conf
named-checkconf

systemctl -f enable named
systemctl start named

cat <<_EOT_
Run set_local_routing.sh then set_iptables.sh.
Test your config to make sure it works.
If everything is ok, then save config using save_routing.sh.
_EOT_

