#!/bin/bash

source ~/notebooks/stepdefs/jenkins-utility/message.conf
source ~/notebooks/stepdefs/jenkins-utility/check_message.sh

(
    fail()
    {
	echo "$*"
	exit 1
    }

    [ -f ~/jenkins-instance-ip ] || fail "File ~/jenkins-instance-ip not found"

    IP="$(< ~/jenkins-instance-ip)"

    [[ "$IP" == *.*.*.* ]] || fail "$IP is not a valid IP address"

    # The next mussel commands returns current and deleted instances,
    # but only the current ones have the :address: field.
    inuse="$(mussel instance index | grep ":address:" | while read thelabel theip; do echo "$theip" ; done)"
    [[ "$inuse" == *$IP* ]] || fail "The address $IP is not currently used by any instancees"
)

check_message "$?" "IP address saved"
