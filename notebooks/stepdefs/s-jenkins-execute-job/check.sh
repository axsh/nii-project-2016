#!/bin/bash
. ./stepdefs/jenkins-utility/functions.sh

# Check do it file for pdf 103 execute jenkins job.
# Evaluated Tasks:
#  Job sample created
#  Job sample2 created
#  Added shell script parameters to sample (config)
#  Made sample2 trigger sample (config)

ssh="ssh root@10.0.2.100 -i ~/mykeypair"
jenkins_dir="/var/lib/jenkins"

jobs=(sample
      sample2)
xml_file=(sample-1.xml
          sample-2.xml)


xml_to_vm

${ssh} <<EOF 2> /dev/null

$(declare -f confirm)
$(declare -f check_job_config)
$(declare -f contains_value)
$(declare -f get_xml_element_value)

pass=true

[[ -d ${jenkins_dir}/jobs/${jobs[0]} ]] || {
    echo -e "${cross_mark} job ${jobs[0]}"
    pass=false
}

[[ -d ${jenkins_dir}/jobs/${jobs[1]} ]] || {
    echo -e "${cross_mark} job: ${jobs[1]}"
    pass=false
}

\${pass} && echo -e "${check_mark} Jobs"

pass=true

! confirm multi /home/${xml_file[0]} ${jenkins_dir}/jobs/${jobs[0]}/config.xml "command" && {
    echo -e "${cross_mark} param: shell script"
    pass=false
}

! confirm single /home/${xml_file[1]} ${jenkins_dir}/jobs/${jobs[1]}/config.xml "childProjects" && {
    echo -e "${cross_mark} param: build trigger"
    pass=false
}

\${pass} && echo -e "${check_mark} Params"

EOF
