#!/bin/bash

source ~/stepdefs/jenkins-utility/message.conf
source ~/stepdefs/jenkins-utility/check_message.sh

INSTANCE_IP=$(<~/vdc_host_ip)
INSTANCE_PORT=$(<~/vdc_instance_port)
ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} uptime

check_message "$?" "SSH is running"
