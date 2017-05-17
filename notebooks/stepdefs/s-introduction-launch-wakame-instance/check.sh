#!/bin/bash

source ~/stepdefs/jenkins-utility/message.conf
source ~/stepdefs/jenkins-utility/check_message.sh

# in the Jupyter notebook, this is run right after doing mussel create
# so give a little time for Wakame-vdc state to change by checking
# ten times, waiting 1 second between each.

if [ "$global_mode" = "my-script" ]; then
    tries=3
else
    # wait longer for provided-script mode so automated builds will work
    tries=30
fi

for i in $(seq 1 $tries); do
    ymloutput="$(mussel instance index)"
    (
        # TODO: parse this better!

	if [[ "$ymloutput" != *running* ]] && [[ "$ymloutput" != *initializing* ]]; then
	    echo "ERROR: No instances are running"
	    exit 1
	fi

	if [[ "$ymloutput" != *cpu_cores:\ 2* ]]; then
	    echo "ERROR: Instance must have 2 CPUs"
	    exit 1
	fi

	if [[ "$ymloutput" != *10.0.2.100* ]]; then
	    echo "WARNING: IP address of instance is not 10.0.2.100"
	fi
    )
    rc="$?"
    [ "$rc" = "0" ] && break
    sleep 1
done

check_message "$rc" "Wakame running"
