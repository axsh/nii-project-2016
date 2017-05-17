#!/bin/bash

sp="-space-"

function check_find_line_with() {
    local passed_check occurances=1
    [[ ${1} =~ ^-?[0-9]+$ ]] && { occurances="${1}" ; shift ; }
    let found=0
    while read -r line ; do
        passed_check=true
        for keyword in "$@" ; do
            # TODO: Convert line to array and have it use contains function
            [[ "${line}" != *"${keyword}"* ]] && { passed_check=false ; break ; }
        done
        $passed_check && {
            found=$(( $found+1 ))
            [[ $found -eq $occurances ]] && return 0 
        }
    done
    return 1
}

function get_line_with() {
    local keyword="${1}"
    while read -r line ; do
        [[ "${line}" == *${keyword}* ]] && {
            echo "${line}"
            return 0
        }
    done
}

function check_not_empty () {
    local input="${1}" element="${2}"
    local content="$(grep -oP '(?<=<'${element}'>).*?(?=</'${element}'>)')"
    [[ ! -z $content ]]
}

function check_param_value() {
    local element="${1}" required_values=( ${2} )
    local content="$(grep -oP '(?<=<'${element}'>).*?(?=</'${element}'>)')"
    # Replace the word "-space- with a space, use for cases when required value consists of multiple words"
    for value in "${required_values[@]//-space-/ }" ; do
        [[ "${content}" != *"${value}"* ]] && {
            return 1
        }
    done
    return 0
}

function check_plugins_exists () {
    plugins="$(ssh -i ~/mykeypair root@10.0.2.100 ls /var/lib/jenkins/plugins/ 2> /dev/null)"
    for plugin in $@;  do
        if [[ "$plugins" != *"$plugin"* ]] ; then
            return 1
        fi
    done
}

### Old functoins

# function check_not_empty () {
#     local job element xml_file

#     case "$1" in
#         "system_config")
#             xml_file="${2}"
#             element="${3}"
#             ;;
#         *)
#             job="${1}"
#             element="${2}"
#             xml_file="/var/lib/jenkins/jobs/${job}/config.xml"
#             ;;
#     esac
#     local content=$(grep -oP '(?<=<'${element}'>).*?(?=</'${element}'>)' "${xml_file}")
#     [[ ! -z $content ]]
# }

# function check_param_value() {
#     local element="${1}" required_values=( ${2} ) job="${3}"
#     local content="$(grep -oP '(?<=<'${element}'>).*?(?=</'${element}'>)' /var/lib/jenkins/jobs/${job}/config.xml)"
#     # Replace the word "-space- with a space, use for cases when required value consists of multiple words"
#     for value in "${required_values[@]//-space-/ }" ; do
#         [[ "${content}" != *"${value}"* ]] && {
#             return 1
#         }
#     done
#     return 0
# }

# # Recieves a job name ($1), number of times ($2) the pattern needs to be found
# # and a list of keywords that a line should consist of
# function check_find_line_with() {
#     local job="${1}" ; shift
#     local passed_check=
#     local occurances="${1}" ; shift
#     let found=0
#     while read -r line ; do
#         passed_check=true
#         for keyword in "$@" ; do
#             # TODO: Convert lien to array and have it use contains function
#             [[ "${line}" != *"${keyword}"* ]] && { passed_check=false ; break ; }
#         done
#         $passed_check && {
#             found=$(( $found+1 ))
#             [[ $found -eq $occurances ]] && return 0
#         }
#     done < /var/lib/jenkins/jobs/${job}/config.xml
#     return 1
# }

# function get_line_with() {
#     local job="${1}" ; shift
#     local keyword="${1}"
#     while read -r line ; do
#         [[ "${line}" == *${keyword}* ]] && {
#             echo "${line}"
#             return 0
#         }
#     done < /var/lib/jenkins/jobs/${job}/config.xml
#     echo "${lines[@]}"
# }

INSTANCE_IP=10.0.2.100

. ~/notebooks/stepdefs/jenkins-utility/message.conf
. ~/notebooks/stepdefs/jenkins-utility/check_message.sh
[[ -f $(dirname $0)/stepdata.conf ]] && . $(dirname $0)/stepdata.conf
jenkins_dir="/var/lib/jenkins/"
job_config="${jenkins_dir}/jobs/${job}/config.xml"

[[ $global_mode == "my-script" ]] && \
    [[ -f $(dirname $0)/save.sh ]] && . $(dirname $0)/save.sh
[[ -f $(dirname $0)/exec.sh ]] && . $(dirname $0)/exec.sh
