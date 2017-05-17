#!/bin/bash

. $(dirname $0)/stepdata.conf

[[ -f $(dirname $0)/xml-data/"${filename##*/}" ]] &&
    scp -i ~/mykeypair -P ${INSTANCE_PORT} $(dirname $0)/xml-data/"${filename##*/}" root@${INSTANCE_IP}:"$filename"
