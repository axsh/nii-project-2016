#!/bin/bash

. ./stepdefs/jenkins-utility/functions.sh
 
# Reset file for pdf 103 execute jenkins job
# Tasks:
#  Install jenkins-cli client if not installed.
#  Create job, sample using predefind configuration file.
#  Create job, sample2 using predefined configuration file.

ssh="ssh root@${INSTANCE_IP} -p ${INSTANCE_PORT} -i ~/mykeypair"
jobs=(sample
      sample2)
xml_file=(sample-1.xml
          sample-2.xml)

xml_to_vm
${ssh} <<EOF 2> /dev/null

$(declare -f reset_job)
$(declare -f check_client_exists)

check_client_exists

reset_job ${jobs[0]} ${xml_file[0]}
reset_job ${jobs[1]} ${xml_file[1]}

EOF
