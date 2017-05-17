#!/bin/bash

source ~/notebooks/stepdefs/jenkins-utility/message.conf
source ~/notebooks/stepdefs/jenkins-utility/check_message.sh

out="$(ssh -qi ~/mykeypair root@10.0.2.100 'rpm -qa' 2>&1)"

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
