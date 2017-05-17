#!/bin/bash

source ~/stepdefs/jenkins-utility/message.conf
source ~/stepdefs/jenkins-utility/check_message.sh

out="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} 'service jenkins status' 2>&1)"
echo "$out"

[[ "$out" == *jenkins*running* ]]
test_passed="$?"
check_message $test_passed "Jenkins running"
