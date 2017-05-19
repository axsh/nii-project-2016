#!/bin/bash

. $(dirname $0)/stepdata.conf

INSTANCE_IP=$(< ~/vdc_host_ip)
INSTANCE_PORT=$(< ~/vdc_instance_port)

[[ -f $(dirname $0)/xml-data/"${filename##*/}" ]] &&
    scp -i ~/mykeypair -P ${INSTANCE_PORT} $(dirname $0)/xml-data/"${filename##*/}" root@${INSTANCE_IP}:"$filename"
