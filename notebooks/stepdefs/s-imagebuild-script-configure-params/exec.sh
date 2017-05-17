
. ~/stepdefs/jenkins-utility/xml-utility.sh

output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${job_config} 2> /dev/null | sed 's/&quot;/\"/g')"
param_names=($(get_xml_element_value "parameterDefinitions" <<< "$output" | grep -oP '(?<=<name>).*?(?=</name>)'))

param_is_set=(
    false
    false
)

for (( i=0 ; i < ${#param_names[@]} ; i++ )) ; do
    found_line=$(get_line_with "*=\$${param_names[$i]}" <<< "$output")
    [[ -z $found_line ]] && { found_line=$(get_line_with "*=\${${param_names[$i]}}" <<< "$output") ; }
    [[ -z $found_line ]] && { found_line=$(get_line_with "*=\"\${${param_names[$i]}}\"" <<< "$output") ; }

    if [[ -z "${found_line%=*}" ]] ; then
        param_name[$i]="Undefined"
    else
        param_name[$i]="${found_line%=*}"
    fi

    param_value[$i]="${found_line#*=}"

    check_find_line_with "${param_name[$i]}=${param_value[$i]}" <<< "$output" && param_is_set[$i]=true
    check_message ${param_is_set[$i]} "Build param: ${param_names[$i]} set as: ${param_name[$i]}"
done

write_file=false

found_line=$(get_line_with "WRITE_FILE=*" <<< "$output")
[[ -z $found_line ]] && value="Missing" || {
    value="${found_line#*=}"
    check_find_line_with "WRITE_FILE=${value}" <<< "$output" && write_file=true
}
check_message $write_file "WRITE_FILE set as: $value"
