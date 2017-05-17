#!/bin/bash

# set -euox

INSTANCE_IP=$(cat ~/vdc_host_ip)
INSTANCE_PORT=$(cat ~/vdc_instance_port)

. $(dirname $0)/stepdata.conf
. ~/stepdefs/jenkins-utility/xml-utility.sh

insert_type="replace"

function load_config() {
    local file="/var/lib/jenkins/jobs/${job}/config.xml"
    local element_name="${1}" insert_type="${2}" element_value="${3}"
    local element_in_document=$(ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} "grep ${element} ${file}" 2> /dev/null)

    if [[ $insert_type == "insert" ]] && [[ ! -z "$element_in_document" ]] ; then
        insert_type="replace"
        element_name="${element}"
    fi

    # The sed here preserves end of line backslashes from being stripped by the bash
    # on the other side of ssh
    sed 's,\\$,BaCkSlash,g'  <<EOF | ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} 2> /dev/null
        $(declare -f xml_load_backup)
        $(declare -f xml_replace_case)
        $(declare -f xml_insert_case)

        value="\$(sed 's,BaCkSlash,\\\\,g' <<"XML_BLOCK"
$element_value
XML_BLOCK
)"
        xml_load_backup "-${insert_type}" "${file}" "${element_name}" "\${value}"
        curl -X POST http://localhost:8080/job/$job/config.xml --data-binary "@${file}"
EOF
}

echo "Loading progress..."
[[ ${#xpaths} -eq 0 ]] || {
    for xpath in "${xpaths[@]}" ; do
	insert_type="replace"
        [[ ${#insert_to} -eq 0 ]] || { contains_value "${xpath}" "${insert_to[@]}" && insert_type="insert" ; }

        student_file="$(dirname $0)/xml-data/${xpath##*/}.data-student"
        [[ -f ${student_file} ]] && {
            load_config "${xpath##*/}" "${insert_type}" "$(cat ${student_file})"
        }
    done
}

bash
