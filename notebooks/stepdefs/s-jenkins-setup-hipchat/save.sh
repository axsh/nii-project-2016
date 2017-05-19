#!/bin/bash

. $(dirname $0)/stepdata.conf

INSTANCE_IP=$(< ~/vdc_host_ip)
INSTANCE_PORT=$(< ~/vdc_instance_port)

scp -i ~/mykeypair -P ${INSTANCE_PORT} root@${INSTANCE_IP}:"$filename" $(dirname $0)/xml-data/ &> /dev/null
