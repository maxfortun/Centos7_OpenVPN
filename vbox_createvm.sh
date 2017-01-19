#!/bin/bash
#Scripting as per https://wiki.centos.org/HowTos/Virtualization/VirtualBox/CentOSguest

# Command line parameters. See usage for details.
VBOX_VM=$1
VBOX_ISO=$2

# Defaults
VBOX_OSTYPE=RedHat_64
VBOX_HDSIZE=16000

#VBoxManage list ostypes
if [ -z "$VBOX_VM" ]; then
	echo "Usage: $0 <name> [iso]"
	echo "Will create a vm with a specified <name> of type $VBOX_OSTYPE"
	echo "If [iso] is specified, will mount it before booting the machine up"
	exit
fi

vminfo=$(VBoxManage showvminfo "$VBOX_VM" 2>/dev/null)
if [ "$?" = "1" ]; then
	VBoxManage createvm --name "$VBOX_VM" --ostype "$VBOX_OSTYPE" --register

	VBoxManage modifyvm "$VBOX_VM" --memory 1024 --vram 128
	VBoxManage modifyvm "$VBOX_VM" --ioapic on
	VBoxManage modifyvm "$VBOX_VM" --boot1 dvd --boot2 disk --boot3 none --boot4 none
	VBoxManage modifyvm "$VBOX_VM" --nic1 bridged --bridgeadapter1 en0
	VBoxManage modifyvm "$VBOX_VM" --mouse usb
	VBoxManage modifyvm "$VBOX_VM" --vrde on --vrdeport 5000

	#VBoxManage setextradata "$VBOX_VM" "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/Protocol" TCP
	#VBoxManage setextradata "$VBOX_VM" "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/GuestPort" 22
	#VBoxManage setextradata "$VBOX_VM” "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/HostPort" 2222

	VBoxManage storagectl "$VBOX_VM" --name "SATA Controller" --add sata --controller IntelAHCI
	VBoxManage storagectl "$VBOX_VM" --name "IDE Controller" --add ide

	VBoxManage showvminfo "$VBOX_VM"
else
	echo "$vminfo"
fi

VBOX_HOME=$(echo "$vminfo"|grep "^Config file:"|sed -e 's#^[^/]*/#/#g' -e 's#/[^/]*$##g')
VBOX_HD="$VBOX_HOME/$VBOX_VM.vdi"
hdinfo=$(VBoxManage showhdinfo "$VBOX_HD" 2>/dev/null)
if [ "$?" = "1" ]; then
	VBoxManage createhd --filename "$VBOX_HD" --size "$VBOX_HDSIZE"
	VBoxManage storageattach "$VBOX_VM" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VBOX_HD"
	VBoxManage showhdinfo "$VBOX_HD"
else
	echo "$hdinfo"
fi

if [ -f "$VBOX_ISO" ]; then
	VBoxManage storageattach "$VBOX_VM" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$VBOX_ISO"
fi

VBoxManage startvm "$VBOX_VM" --type headless

