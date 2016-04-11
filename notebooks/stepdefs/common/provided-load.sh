#!/bin/bash

# set -euox

. /home/centos/notebooks/stepdefs/jenkins-utility/xml-utility.sh

insert_type="-replace"

function load_config() {
    local file="/var/lib/jenkins/jobs/${job}/config.xml"
    local element_name="${1}" insert_type="${2}"  element_value="${3}"
    local element_in_document=$(ssh -i /home/centos/mykeypair root@10.0.2.100 "grep ${element} ${file}" 2> /dev/null)

    if [[ $insert_type == "insert" ]] && [[ ! -z "$element_in_document" ]] ; then
        insert_type="replace"
        element_name="${element}"
    fi

    ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF  2> /dev/null
        $(declare -f xml_load_backup)
        $(declare -f xml_replace_case)
        $(declare -f xml_insert_case)

        value="\$(cat <<"XML_BLOCK"
$element_value
XML_BLOCK
)"
        xml_load_backup "-${insert_type}" "${file}" "${element_name}" "\${value}"
        curl -X POST http://localhost:8080/job/$job/config.xml --data-binary "@${file}"

EOF
}

[[ ${#xpaths} -eq 0 ]] || {
    for xpath in "${xpaths[@]}" ; do
        insert_type="replace"

        [[ ${#insert_to} -eq 0 ]] || { contains_value "${xpath}" "${insert_to[@]}" && insert_type="insert" ; }
        echo "Loading path ${xpath}. ($insert_type)"
        load_config "${xpath##*/}" "${insert_type}" "$(cat $(dirname $0)/xml-data/${xpath##*/}.data)"
    done
}
