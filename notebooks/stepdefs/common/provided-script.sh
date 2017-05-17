#!/bin/bash

INSTANCE_IP=$(cat ~/vdc_host_ip)
INSTANCE_PORT=$(cat ~/vdc_instance_port)

[[ -f $(dirname $0)/stepdata.conf ]] && . $(dirname $0)/stepdata.conf
[[ -f $(dirname $0)/pre-exec.sh ]] && . $(dirname $0)/pre-exec.sh

bash
