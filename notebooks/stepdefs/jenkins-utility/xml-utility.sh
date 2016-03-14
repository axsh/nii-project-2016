#!/bin/bash

function replace_git_repo() {
    local file="${1}" user_git_repo="https://gituhb.com/${GITHUB_USER}/${GITHUB_REPO}.git"
    local default_repo=$(cat /home/centos/notebooks/stepdefs/jenkins-config/${file} | grep -oP '(?<=<url>).*?(?=</url>)')

    ${ssh} <<EOF 2> /dev/null
        echo ${user_git_repo}
        sed -i "s@${default_repo}@${user_git_repo}@g" /home/${file}
EOF
}

function xml_to_vm() {
    for file in "${xml_file[@]}"; do
        scp -i /home/centos/mykeypair /home/centos/notebooks/stepdefs/jenkins-config/${file} root@10.0.2.100:/home &> /dev/null
        if [ ! -z ${GITHUB_USER} ] && [ ! -z ${GITHUB_REPO} ] ; then
            replace_git_repo ${file}
        fi
    done
}

# Compares a string value ($1) to all values in an array ($2)
# and returns true if a match is found.

function contains_value() {
    local match="${1}"

    for value in "${@:2}"; do
        [[ "${match}" == "${value}" ]] &&
            return 0;
    done
    return 1
}


# Read and returns values from a xml at specified element ($1) where value spans
# accross multiple lines or element has attribues attatched.
# ($2 can be set to true to enable output from the line where element is detected)

function get_xml_element_value() {
    local element_name=${1} in_element=false return_on_detected=${2:-false}

    while read -r line; do
        case "$line" in
            # TODO: Find a better way to match elements which have attributes attached.
            *\<"${element_name} "*)
                echo ${line} | grep -oP '>\K.*?(?=<)'
                ;;
            #TODO: Implement a condition that matches when requested element is a single line
            *\<"${element_name}"\>*)
                ${return_on_detected} && echo "${line}" | sed 's/<'${element_name}'>//g'
                in_element=true
                ;;
            *\</"${element_name}"\>*)
                ${return_on_detected} && echo "${line}" | sed 's/<\/'${element_name}'>//g'
                in_element=false
                ;;
            *)
                if $in_element; then
                    echo "$line"
                fi
                ;;
        esac
    done
}

# Confirms that the values of specified element ($4) in a file ($3) matches
# with the values in a default file ($2).
# Due to the xml structure we used different parsing methods ($1) depending
# on the circumstance and what sort of field we are requesting a value from.
#  ( methods : single, multi, nested )

function confirm() {
    local method=${1} target_xml=${2} try_xml=${3} element_name="${4}"
    local required_values=("${5}")

    [[ -f ${try_xml} ]] || { echo "Test xml not found." ; return 1 ; }
    [[ -f ${target_xml} ]] || { echo "Target xml not found." ; return 1 ; }
    [[ ! -z ${element_name} ]] || { echo "No element specified" ; return 1 ; }

    function single_line_value() {
        local parsed_value=$(cat ${try_xml} | grep -oP '(?<=<'${element_name}'>).*?(?=</'${element_name}'>)')
        local target_value=$(cat ${target_xml} | grep -oP '(?<=<'${element_name}'>).*?(?=</'${element_name}'>)')
        [[ "${parsed_value}" == "${target_value}" ]]
    }

    function multi_line_value() {
        local parsed_values=( $(echo "$(cat ${try_xml} | get_xml_element_value "${element_name}" true)" ) )
        local target_values=( $(echo "$(cat ${target_xml} | get_xml_element_value "${element_name}" true)" ) )

        for required_value in "${target_values[@]}"; do
            if ! contains_value "${required_value}" "${parsed_values[@]}" ; then
                return 1
            fi
        done
    }

    # Check for exact match (order and content)
    # TODO: Add ignore for blank lines
    function multi_line_value2() {
        local parsed_values=( "$(cat ${try_xml} | get_xml_element_value "${element_name}" true)" )
        local target_values=( "$(cat ${target_xml} | get_xml_element_value "${element_name}" true)" )

        [[ "${parsed_values}" == "${target_values}" ]]
    }

    function nested_line_value () {
        for value in ${required_values[@]}; do
            target_values+=( $(cat ${target_xml} | \
                                      get_xml_element_value ${element_name} | \
                                      grep -oP '(?<=<'${value}'>).*?(?=</'${value}'>)')
                           )
            parsed_values+=( $(cat ${try_xml} | \
                                      get_xml_element_value ${element_name} | \
                                      grep -oP '(?<=<'${value}'>).*?(?=</'${value}'>)')
                          )
        done
        # TODO: Switch to compare the contents of the arrays instead
        [[ "${parsed_values[@]}" == "${target_values[@]}" ]]
    }


    case "${method}" in
        "single") single_line_value ;;
        "multi") multi_line_value ;;
        "multi2") multi_line_value2 ;;
        "nested") nested_line_value ;;
    esac
}
