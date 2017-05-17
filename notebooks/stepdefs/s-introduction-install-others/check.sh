#!/bin/bash

source ~/stepdefs/jenkins-utility/message.conf
source ~/stepdefs/jenkins-utility/check_message.sh

INSTANCE_IP=$(cat ~/vdc_host_ip)
INSTANCE_PORT=$(cat ~/vdc_instance_port)

out="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} 'rpm -qa' 2>&1)"

packages=(
    git 
    iputils nc 
    qemu-img 
    parted kpartx 
    rpm-build automake createrepo 
    openssl-devel zlib-devel readline-devel 
    gcc
)

for p in "${packages[@]}"; do
    grep -q ^"$p" <<< "$out" 
    check_message "$?" "Installed $p"
done
