# OpenVPN

Some scripts that are required for openvpn to work

## SELinux
If you have SELinux running, you may want to run openvpn_unpriv_hack.sh to allow log writing, script execution and sudo.

## Routing
Will need to set the routing to allow the initial incoming vpn handshake and world access.

Run set_local_routing.sh then set_iptables.sh. Test your config to make sure it works. If everything is ok, then persist using iptables-save > /etc/sysconfig/iptables.

