#!/bin/bash
. ./stepdefs/jenkins-utility/functions.sh

# Check do it file for pdf 105 install hipchat

ssh="ssh root@10.0.2.100 -i ~/mykeypair"
jobs=(test-notification)
xml_file=(jenkins.plugins.hipchat.HipChatNotifier.xml
         sample-hipchat-0.xml)
jenkins_dir="/var/lib/jenkins"

xml_to_vm

${ssh} <<EOF 2> /dev/null

$(declare -f get_xml_element_value)
$(declare -f check_plugins_exists)
$(declare -f check_empty)
$(declare -f confirm)


! check_plugins_exists "hipchat" &&
    echo -e "${cross_mark} Plugins" || echo -e "${check_mark} Plugins"

! check_empty ${xml_file[0]} room && echo -e "${check_mark} HipChat Room" || echo -e "${cross_mark} HipChat Room"
! check_empty ${xml_file[0]} token && echo -e "${check_mark} HipChat Token" || echo -e "${cross_mark} HipChat Token"

[[ ! -d ${jenkins_dir}/jobs/${jobs[0]} ]] &&
    echo -e "${cross_mark} Job" || echo -e "${check_mark} Job"

! confirm nested /home/${xml_file[1]} ${jenkins_dir}/jobs/${jobs[0]}/config.xml jenkins.plugins.hipchat.model.NotificationConfig "notificationType notifyEnabled" && 
    echo -e "${cross_mark} Params" || echo -e "${check_mark} Params"

EOF
