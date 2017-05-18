#!/bin/bash

. $(dirname $0)/stepdata.conf

scp -i ~/mykeypair -P ${INSTANCE_PORT} root@${INSTANCE_IP}:"$filename" $(dirname $0)/xml-data/ &> /dev/null
