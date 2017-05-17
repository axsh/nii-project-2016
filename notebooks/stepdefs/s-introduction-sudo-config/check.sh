#!/bin/bash

source ~/notebooks/stepdefs/jenkins-utility/message.conf
source ~/notebooks/stepdefs/jenkins-utility/check_message.sh

out="$(ssh -qi ~/mykeypair root@10.0.2.100 'grep jenkins /etc/sudoers' 2>&1)"

echo "$out"

[[ "$out" == *jenkins* ]]
test_passed="$?"
check_message $test_passed "Added jenkins to sudoers"
