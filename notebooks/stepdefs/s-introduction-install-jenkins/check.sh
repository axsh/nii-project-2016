#!/bin/bash

source ~/stepdefs/jenkins-utility/message.conf
source ~/stepdefs/jenkins-utility/check_message.sh

INSTANCE_IP=$(cat ~/vdc_host_ip)
INSTANCE_PORT=$(cat ~/vdc_instance_port)

ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} 'rpm -qa' | grep jenkins

check_message "$?" "Installed Jenkins"
