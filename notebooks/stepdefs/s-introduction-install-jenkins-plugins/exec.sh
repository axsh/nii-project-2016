#!/bin/bash

ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} <<EOF 2> /dev/null
    $(declare -f check_plugins_exists)

    if check_plugins_exists rbenv hipchat git git-client parameterized-trigger ; then
        echo "TASK COMPLETED"
    else
        echo "THIS TASK HAS NOT BEEN DONE"
    fi       
    
EOF
