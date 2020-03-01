#!/bin/bash

vbmg () { /mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe "$@"; }

NET_NAME="NET_4640"
VM_NAME="TODO4640"
SSH_PORT="12022"
WEB_PORT="12080"
SED_PROGRAM="/^Config file:/ { s/^.*:\s\+\(\S\+\)/\1/; s|\\\\|/|gp }"
VBOX_FILE=$(vbmg showvminfo "$VM_NAME" | sed -ne "$SED_PROGRAM")
VM_DIR=$(dirname "$VBOX_FILE")

clean_all () {
    vbmg natnetwork remove --netname "$NET_NAME"
    vbmg unregistervm TODO4640 --delete
}

create_network () {
    vbmg natnetwork add --netname "$NET_NAME" --network "192.168.230.0/24"  --dhcp "off" --ipv6 "off" --port-forward-4 "SSH:tcp:[]:12022:[192.168.230.10]:22" --port-forward-4 "HTTP:tcp:[]:12080:[192.168.230.10]:80" --port-forward-4 "PXESSH:tcp:[]:12222:[192.168.230.200]:22"

}

create_vm () {
    vbmg createvm --name "$VM_NAME" --ostype "RedHat_64" --register
    vbmg modifyvm "$VM_NAME" --memory 1536 --cpus 1 --nic1 natnetwork --nat-network1 "$NET_NAME" --mouse usbtablet --audio none

    vbmg createmedium disk --filename "$VM_DIR"/CentOS.vdi --size 10240
    
    vbmg storagectl TODO4640 --name SATA --add SATA --controller IntelAhci --bootable on
    vbmg storageattach TODO4640 --storagectl SATA --port 0 --device 0 --type hdd --medium "$VM_DIR"/CentOS.vdi

    vbmg storagectl TODO4640 --name IDE --add IDE
    vbmg storageattach TODO4640 --storagectl IDE --port 1 --device 1 --type dvddrive --medium emptydrive

    vbmg modifyvm "$VM_NAME" --boot1 disk --boot2 net

}

echo "Starting script..."

clean_all
create_network
create_vm

echo "DONE!"