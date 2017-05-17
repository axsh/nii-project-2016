#!/bin/bash

. ./stepdefs/jenkins-utility/functions.sh

# Reset file for pdf 103 install git
# Tasks:
#  Install jenkins-cli client if not installed.
#  Install plugins: rbenv.
#  Create job sample using predefined configuration file.
#  Restart jenkins

ssh="ssh root@${INSTANCE_IP} -p ${INSTANCE_PORT} -i ~/mykeypair"
jobs=(test-rbenv)
xml_file=(sample-unit-test-0.xml)

xml_to_vm
${ssh} <<EOF 2> /dev/null

$(declare -f reset_job)
$(declare -f check_client_exists)
$(declare -f install_plugins)

check_client_exists

install_plugins "rbenv"

reset_job ${jobs[0]} ${xml_file[0]}

service jenkins restart

EOF
