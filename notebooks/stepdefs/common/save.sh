#!/bin/bash

# set -euox

INSTANCE_IP=$(cat ~/vdc_host_ip)
INSTANCE_PORT=$(cat ~/vdc_instance_port)

. $(dirname $0)/stepdata.conf
. ~/stepdefs/jenkins-utility/xml-utility.sh

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

    ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} <<EOF 2> /dev/null
        $(declare -f xml_save_backup)
        xml_save_backup "${file}" "${element_name}" "${xpath}"
EOF
    scp -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT}:/tmp/"${element_name}".data-student $(dirname $0)/xml-data/"${base_element}".data-student &> /dev/null
    [[ -f $(dirname $0)/xml-data/"${base_element}".data-student ]] || { echo "[WARNING] Expected configuration data not found." ; return 1 ; }
    incremental_log $(dirname $0)/xml-data/"${base_element}".data-student
}

echo "Saving progress..."
for xpath in "${xpaths[@]}" ; do
    base_element="${xpath##*/}"
    [[ ${#insert_to} -eq 0 ]] || { contains_value "${xpath}" "${insert_to[@]}" && xpath="${xpath}/${element}" ; }

    save_config "${xpath}" "${base_element}"
done

