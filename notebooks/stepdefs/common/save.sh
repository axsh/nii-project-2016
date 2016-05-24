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
    cp "${filename}" "${filename}-${cnt}"
}

function save_config() {
    local file="/var/lib/jenkins/jobs/${job}/config.xml"
    local xpath="${1}" base_element="${2}" element_name="${xpath##*/}"

    ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF 2> /dev/null
        $(declare -f xml_save_backup)
        xml_save_backup "${file}" "${element_name}" "${xpath}"
EOF
    scp -i /home/centos/mykeypair root@10.0.2.100:/tmp/"${element_name}".data-student $(dirname $0)/xml-data/"${base_element}".data-student &> /dev/null
    incremental_log $(dirname $0)/xml-data/"${base_element}".data-student
}

echo "Saving progress..."
for xpath in "${xpaths[@]}" ; do
    base_element="${xpath##*/}"
    [[ ${#insert_to} -eq 0 ]] || { contains_value "${xpath}" "${insert_to[@]}" && xpath="${xpath}/${element}" ; }

    save_config "${xpath}" "${base_element}"
done

