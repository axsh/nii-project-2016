#!/bin/bash

source ~/stepdefs/jenkins-utility/message.conf
source ~/stepdefs/jenkins-utility/check_message.sh

INSTANCE_IP=$(cat ~/vdc_host_ip)
INSTANCE_PORT=$(cat ~/vdc_instance_port)

KEYFILE=/tmp/jenkins-ci.org.key
[ -f $KEYFILE ] || \
    wget http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key \
	 -O $KEYFILE 2>/dev/null

# The next gpg runs in the 1box VM (i.e. not the instance). The first time
# it is run, it outputs some messages about the setup of ~/.gpg. Now
# these are sent to a file to keep them from cluttering the Jupyter display.
KEYID=$(echo $(gpg --throw-keyids < $KEYFILE 2>/tmp/gpg.stderr)|cut -c11-18|tr [A-Z] [a-z])

# from http://unix.stackexchange.com/questions/21226/how-can-i-verify-that-a-pgp-key-is-imported-into-rpm

ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} <<EOF 2>/dev/null
rpm -q gpg-pubkey-$KEYID
EOF

[ "$?" = "0" ]
check_message "$?" "Public key imported"
