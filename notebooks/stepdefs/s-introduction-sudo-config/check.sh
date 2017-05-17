#!/bin/bash

source ~/stepdefs/jenkins-utility/message.conf
source ~/stepdefs/jenkins-utility/check_message.sh

out="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} 'grep jenkins /etc/sudoers' 2>&1)"

echo "$out"

[[ "$out" == *jenkins* ]]
test_passed="$?"
check_message $test_passed "Added jenkins to sudoers"
