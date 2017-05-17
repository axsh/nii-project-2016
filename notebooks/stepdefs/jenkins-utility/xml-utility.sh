#!/bin/bash

function xml_to_vm() {
    for file in "${xml_file[@]}"; do
        scp -i ~/mykeypair ~/stepdefs/jenkins-config/${file} root@${INSTANCE_IP} -p ${INSTANCE_PORT}:/home &> /dev/null
        if [ ! -z ${GITHUB_USER} ] && [ ! -z ${GITHUB_REPO} ] ; then
            replace_git_repo ${file}
        fi
    done
}

function xml_save_backup () {
    local file="${1}"
    local element_name="${2}"
    local xpath="${3}"
    local xml_data=$(xmllint "${file}"  --shell <<<'cat '${xpath}'' | ( read  ln ; v="$(cat)" ; echo "${v%$'\n'*}" ))

    [[ -z ${xml_data} ]] || echo "${xml_data}" > /tmp/"${element_name}".data-student
}

function xml_insert_case() {
    # Insert the xml starting after the starting tag, which is assumed to exist
    # This function uses and sets variables from the calling context.
    case "$ln" in
        $pattern1c)  # both start and end tags on one line
            printf "%s" "${ln%%>*}>"  # just the start tag
            printf "%s\n" "$replacementtext"
            replacedit=true
            printf "%s\n" "${ln#*>}"  # everything after the start tag
            ;;
        $pattern1a | $pattern1b)  # a start tag that ends with />  (i.e. no end tag)
            printf "%s\n" "${ln%%/>*}>"  # just the start tag (minus the /)
            printf "%s\n" "$replacementtext"
            printf "</%s>\n" "$elementname"  # create a new end tag
            printf "%s\n" "${ln#*>}"  # everything after the start tag
            replacedit=true
            ;;
        $pattern2a | $pattern2b)  # Two separate tags on different lines
	    # Maybe this can be handled just like pattern1c.
	    # Going to copy/paste code above to make the code clearer.
            printf "%s\n" "${ln%%>*}>"  # just the start tag
            printf "%s\n" "$replacementtext"
            replacedit=true
	    if false; then
		# disabled this...now anything after the first tag will be dropped
		printf "%s\n" "${ln#*>}"  # everything after the start tag
	    fi
	    # Unlike in the xml_replace_case, there is no need to
	    # search for the closing tag.  Just sending the rest
	    # of the file to output should be OK.
            replacedit=true
            ;;
        *)
            printf "%s\n" "$ln"
            ;;
    esac
}

function xml_replace_case() {
    # This function uses and sets variables from the calling context.
    case "$ln" in
        $pattern1a | $pattern1b | $pattern1c)
            $replacedit && reportfailed "target element $elementname appeared twice"
            # just replace this one line
            printf "%s\n" "$replacementtext"
            replacedit=true
            ;;
        $pattern2a | $pattern2b)
            $replacedit && reportfailed "target element $elementname appeared twice"
            # scan until end pattern
            foundit=false
            while IFS= read -r ln; do
                [[ "$ln" == $endpattern1 ]] && foundit=true && break
            done
            $foundit || reportfailed "Matching </$elementname>" not found
            # insert the rest here
            printf "%s\n" "$replacementtext"
            replacedit=true
            ;;
        *)
            printf "%s\n" "$ln"
            ;;
    esac
}

function xml_load_backup () {
    doinsert=false
    [ "$1" = "-insert" ] && { doinsert=true ; shift ; }
    [ "$1" = "-replace" ] && { doinsert=false ; shift ; }

    targetfile="$1"
    elementname="$2"
    replacementtext="$3"

    reportfailed()
    {
        echo "Script failed...exiting. ($*)" 1>&2
        exit 255
    }
    
    [ -f "$targetfile" ] || reportfailed "XML file $1 not found"
    
    
    # element on one line
    pattern1a="*<$elementname/>*"
    pattern1b="*<$elementname */>*"
    pattern1c="*<$elementname>*</$elementname>*"
    
    # element on multiple line
    pattern2a="*<$elementname>*"
    pattern2b="*<$elementname *"
    endpattern1="*</$elementname>*"
    
    # Current Assumptions:
    # - The target element only appears once.
    # - Nothing unrelated to the target element appears on the same line as its markers.
    #   (Because those lines get deleted entirely)
    # - The elementname can not appear as the last line in the file, or else the
    #   code will add a new line, whether one existed in the original file or not.
    
    mv "$targetfile"  "$targetfile.org"
    
    replacedit=false
    while IFS= read -r ln; do
	if $doinsert; then
	    xml_insert_case
	else
	    xml_replace_case
	fi
        if $replacedit; then
            # we are using cat here to output the rest of the file, because
            # jenkins is sensitive to whether a newline appears at the end
            # of the file.  It is hard to make bash handle that case, so
            # let cat handle it and then exit.
            # (Therefore the "appeared twice" message above will never happen, BTW)
            cat
            break
        fi
    done >"$targetfile"   <"$targetfile.org"
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
        local parsed_value=$(grep -oP '(?<=<'${element_name}'>).*?(?=</'${element_name}'>)' <<< ${try_xml})
        local target_value=$(grep -oP '(?<=<'${element_name}'>).*?(?=</'${element_name}'>)' <<< ${target_xml})
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
