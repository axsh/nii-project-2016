#!/bin/bash


original='\033[0m'
red='\033[00;31m'
green='\033[00;32m'
check_mark="[${green}\xE2\x9C\x93${original}]"
cross_mark="[${red}\xE2\x9C\x97${original}]"
sp="-space-"

function check_plugins_exists () {
    for plugin in $@;  do
        if [[ ! -f /var/lib/jenkins/plugins/${plugin}.jpi ]]; then
            return 1
        fi
    done
}

function check_not_empty () {
    local job element xml_file

    case "$1" in
        "system_config")
            xml_file="${2}"
            element="${3}"
            ;;
        *)
            job="${1}"
            element="${2}"
            xml_file="/var/lib/jenkins/jobs/${job}/config.xml"
            ;;
    esac
    local content=$(grep -oP '(?<=<'${element}'>).*?(?=</'${element}'>)' "${xml_file}")
    [[ ! -z $content ]]
}

function check_param_value() {
    local element="${1}" required_values=( ${2} ) job="${3}"
    local content="$(grep -oP '(?<=<'${element}'>).*?(?=</'${element}'>)' /var/lib/jenkins/jobs/${job}/config.xml)"
    # Replace the word "-space- with a space, use for cases when required value consists of multiple words"
    for value in "${required_values[@]//-space-/ }" ; do
        [[ "${content}" != *"${value}"* ]] && {
            return 1
        }
    done
    return 0
}

# Same as below but without the first parameter (job name).
# Input is taken from stdin instead of a job's config.xml.
function check_find_line_with_for_stdin() {
    local passed_check=
    local occurances="${1}" ; shift
    let found=0

    while read -r line ; do
        passed_check=true
        for keyword in $@ ; do
            [[ ${line} != *"${keyword}"* ]] && { passed_check=false ; break ; }
        done
        $passed_check && {
            found=$(( $found+1 ))
            [[ $found -eq $occurances ]] && return 0
        }
    done
    return 1
}

# Recieves a job name ($1), number of times ($2) the pattern needs to be found
# and a list of keywords that a line should consist of
function check_find_line_with() {
    local job="${1}" ; shift
    check_find_line_with_for_stdin "$@" < /var/lib/jenkins/jobs/${job}/config.xml
}

[[ -f $(dirname $0)/stepdata.conf ]] && . $(dirname $0)/stepdata.conf
[[ $global_mode == "my-script" ]] && . $(dirname $0)/save.sh
[[ -f $(dirname $0)/exec.sh ]] && . $(dirname $0)/exec.sh

