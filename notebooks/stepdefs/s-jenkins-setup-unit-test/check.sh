#!/bin/bash
. ./stepdefs/jenkins-utility/functions.sh

# Check do it file for pdf 106 setup jenkins unit test.
# Evaluated Tasks:
#  Plugin installed: rbenv
#  Job test-rbenv created
#  Added shell script parameters to test-rbenv (config)

ssh="ssh root@10.0.2.100 -i ~/mykeypair"
jenkins_dir="/var/lib/jenkins"

jobs=(test-rbenv)
xml_file=(sample-unit-test-0.xml)

# Read an xml file and retuns the contents from named element ($1)
# Starting from the line it is detected until and including the line where
# closure is detected. 

function confirm_attributed_single_value() {
    local try_xml=${1} target_xml=${2} element=${3}
    local target=$(cat ${try_xml} | get_xml_element_value ${element})
    local parsed=$(cat ${target_xml} | get_xml_element_value ${element})

    [[ "${target}" == "${parsed}" ]]
}

xml_to_vm

${ssh} <<EOF 2> /dev/null


$(declare -f get_xml_element_value)
$(declare -f confirm)
$(declare -f confirm_attributed_single_value)
$(declare -f check_job_config)
$(declare -f contains_value)
$(declare -f check_plugins_exists)

! check_plugins_exists "rbenv" &&
    echo -e "${cross_mark} Plugins" || echo -e "${check_mark} Plugins"

[[ ! -d ${jenkins_dir}/jobs/${jobs[0]} ]] &&
    echo -e "${cross_mark} Jobs" || echo -e "${check_mark} Jobs"

pass=true

! confirm_attributed_single_value /home/${xml_file[0]} ${jenkins_dir}/jobs/${jobs[0]}/config.xml "version" && {
    echo -e "${cross_mark} param: ruby version"
    pass=false
}

! confirm multi2 /home/${xml_file[0]} ${jenkins_dir}/jobs/${jobs[0]}/config.xml "command" && {
    echo -e "${cross_mark} param: shell script"
    pass=false
}

\${pass} && echo -e "${check_mark} Params"

EOF
