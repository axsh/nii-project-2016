#!/bin/bash

source ~/notebooks/stepdefs/jenkins-utility/message.conf
source ~/notebooks/stepdefs/jenkins-utility/check_message.sh

out="$(ssh -qi ~/mykeypair root@10.0.2.100 'service jenkins status' 2>&1)"
echo "$out"

[[ "$out" == *jenkins*running* ]]
test_passed="$?"
check_message $test_passed "Jenkins running"
