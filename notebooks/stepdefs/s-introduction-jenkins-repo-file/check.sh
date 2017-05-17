#!/bin/bash

source ~/stepdefs/jenkins-utility/message.conf
source ~/stepdefs/jenkins-utility/check_message.sh

: "${IP:=$(cat ~/vdc_host_ip) -p $(cat ~/vdc_instance_port)}"
ssh -qi ~/mykeypair "root@$IP" '[ -f /etc/yum.repos.d/jenkins.repo ]'

check_message "$?" "Downloaded jenkins repo"
