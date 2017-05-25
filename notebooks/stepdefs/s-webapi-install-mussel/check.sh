#!/bin/bash
. ~/stepdefs/jenkins-utility/message.conf
. ~/stepdefs/jenkins-utility/check_message.sh

INSTANCE_IP="$(< ~/vdc_host_ip)"
INSTANCE_PORT="$(<~/vdc_instance_port)"
ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} "[[ -f /opt/axsh/wakame-vdc/client/mussel/bin/mussel ]] " 2> /dev/null

test_passed=$?
check_message $test_passed "Mussel installed"


