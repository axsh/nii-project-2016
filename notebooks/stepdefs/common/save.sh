#!/bin/bash

# set -euox

. $(dirname $0)/stepdata.conf
. /home/centos/notebooks/stepdefs/jenkins-utility/xml-utility.sh

function incremental_log() {
    local filename="${1}"
    let cnt=0
    while [[ -f "$filename-${cnt}" ]] ; do
	cnt=$(( cnt + 1 ))
    done
    cp ${filename} ${filename}-${cnt}
}

function save_config() {
    local file="/var/lib/jenkins/jobs/${job}/config.xml"
    local xpath="${1}" element_name="${xpath##*/}" base_node="${2}"

    ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF 2> /dev/null
        $(declare -f xml_save_backup)
        xml_save_backup "${file}" "${element_name}" "${xpath}"
EOF
    if [[ ! -z $base_node ]] ; then
        scp -i /home/centos/mykeypair root@10.0.2.100:/tmp/"${element_name}".data-student $(dirname $0)/xml-data/"${2}".data-student &> /dev/null
        incremental_log $(dirname $0)/xml-data/"${2}".data-student
    else
        scp -i /home/centos/mykeypair root@10.0.2.100:/tmp/"${element_name}".data-student $(dirname $0)/xml-data/ &> /dev/null
        incremental_log $(dirname $0)/xml-data/"${element_name}".data-student
    fi
}

echo "Saving progress..."
[[ ${#xpaths} -eq 0 ]] || {
    for xpath in "${xpaths[@]}" ; do
        [[ ${#insert_to} -eq 0 ]] || {
            unset base_node
            contains_value "${xpath}" "${insert_to[@]}" && {
                base_node="${xpath##*/}"
                xpath="${element}"
            }
        }
        save_config "${xpath}" "${base_node}"
    done
}



