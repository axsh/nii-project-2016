#!/bin/bash

source ~/notebooks/stepdefs/jenkins-utility/message.conf
source ~/notebooks/stepdefs/jenkins-utility/check_message.sh

: ${IP:=10.0.2.100}

output="$(ssh -qi ~/mykeypair root@${IP} 'curl -I -s http://localhost:8080/')"

test_passed=fail

grep -q "200 OK" <<< "$output" && test_passed=true

check_message $test_passed "Jenkins running"
