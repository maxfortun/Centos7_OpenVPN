#!/bin/bash
# Instructions from https://community.openvpn.net/openvpn/wiki/UnprivilegedUser

cd $(dirname $0)

basename=$(basename $0 .sh)

cat > $basename.te <<_EOT_

module $basename 1.0;

require {
        type openvpn_t;
        type sudo_exec_t;
        class file { read open execute getattr execute_no_trans };
        class process setrlimit;
        class capability sys_resource;
}

#============= openvpn_t ==============
allow openvpn_t sudo_exec_t:file { read open execute getattr execute_no_trans};
allow openvpn_t self:process setrlimit;
allow openvpn_t self:capability sys_resource;

_EOT_

checkmodule -M -m -o $basename.mod $basename.te
semodule_package -o $basename.pp -m $basename.mod
semodule -i $basename.pp
semodule -l | grep openvpn

