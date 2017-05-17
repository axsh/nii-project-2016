#!/bin/bash

source ~/stepdefs/jenkins-utility/message.conf
source ~/stepdefs/jenkins-utility/check_message.sh

INSTANCE_IP=$(cat ~/vdc_host_ip)
INSTANCE_PORT=$(cat ~/vdc_instance_port)

output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} 'curl -I -s http://localhost:8080/')"

test_passed=fail

grep -q "200 OK" <<< "$output" && test_passed=true

check_message $test_passed "Jenkins running"
