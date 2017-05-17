#!/bin/bash
. ./stepdefs/jenkins-utility/functions.sh

# Check do it file for pdf 104 install git
# Evaluated Tasks:
#  Plugins installed: git, git-client
#  Git related fields in system config not empty.
#  Job sample created
#  Added url parameter to sample (config git parameter)
#  Added build schedule (config)

ssh="ssh root@${INSTANCE_IP} -p ${INSTANCE_PORT} -i ~/mykeypair"
jobs=(sample)
xml_file=(hudson.plugins.git.GitSCM.xml
         sample-git-1.xml)
jenkins_dir="/var/lib/jenkins"

xml_to_vm

${ssh} <<EOF 2> /dev/null

$(declare -f check_job_config)
$(declare -f check_plugins_exists)
$(declare -f check_empty)
$(declare -f confirm)

! check_plugins_exists "git git-client" &&
    echo -e "${cross_mark} Plugins" || echo -e "${check_mark} Plugins"

! check_empty ${xml_file[0]} globalConfigName && echo -e "${check_mark} Git user" || echo -e "${cross_mark} Git user."
! check_empty ${xml_file[0]} globalConfigEmail && echo -e "${check_mark} Git email" || echo -e "${cross_mark} Git email."

[[ ! -d ${jenkins_dir}/jobs/${jobs} ]] &&
    echo -e "${cross_mark} Job" || echo -e "${check_mark} Job"

pass=true

! confirm single /home/${xml_file[1]} ${jenkins_dir}/jobs/${jobs[0]}/config.xml "url" && {
    echo -e "${cross_mark} param: url"
    pass=false
}

! confirm single /home/${xml_file[1]} ${jenkins_dir}/jobs/${jobs[0]}/config.xml "spec" && {
    echo -e "${cross_mark} param: chedule"
    pass=false 
}

\${pass} && echo -e "${check_mark} Params"

EOF
