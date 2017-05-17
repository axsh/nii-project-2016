#!/bin/bash

. ./stepdefs/jenkins-utility/functions.sh
 
# Reset file for pdf 103 install git
# Tasks:
#  Install jenkins-cli client if not installed.
#  Install plugins: git git-client.
#  Set the parameters for interracting with git inside jenkins (system config)
#  Create job sample using predefined configuration file.
#  Restart jenkins

ssh="ssh root@${INSTANCE_IP} -p ${INSTANCE_PORT} -i ~/mykeypair"
jobs=(sample)
xml_file=(hudson.plugins.git.GitSCM.xml
         sample-git-1.xml)

xml_to_vm
${ssh} <<EOF 2> /dev/null

$(declare -f reset_job)
$(declare -f check_client_exists)
$(declare -f install_plugins)

check_client_exists

install_plugins "git git-client"

cp /home/${xml_file[0]} /var/lib/jenkins

reset_job ${jobs[0]} ${xml_file[1]}

service jenkins restart

EOF
