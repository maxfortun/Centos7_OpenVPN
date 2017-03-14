# OpenVPN

Some scripts and info that are required for openvpn to work

## General

(https://www.privacytools.io)

(https://www.digitalocean.com/community/tutorials/how-to-setup-and-configure-an-openvpn-server-on-centos-7)

## SELinux
If you have SELinux running, you may want to run openvpn_unpriv_hack.sh to allow log writing, script execution and sudo.

## Routing
Need to set the routing to allow the initial incoming vpn handshake and world access.

You will need this in order to apply rules and routes on reboot: yum install -y NetworkManager-config-routing-rules

Run set_local_routing.sh then set_iptables.sh. Test your config to make sure it works. If everything is ok, then persist using save_routing.sh.

Make sure your default route is properly set in /etc/sysconfig/network

It may be possible to avoid using iptables and use firewalld instead. I have not tested these.   
firewall-cmd --permanent --add-service openvpn   
firewall-cmd --permanent --add-masquerade   

