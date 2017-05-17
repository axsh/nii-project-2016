#!/bin/bash

. $(dirname $0)/stepdata.conf

scp -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT}:"$filename" $(dirname $0)/xml-data/ &> /dev/null
