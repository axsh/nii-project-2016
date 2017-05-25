. ~/stepdefs/jenkins-utility/xml-utility.sh

output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${job_config} 2> /dev/null | sed 's/&quot;/\"/g')"

param_names=($(get_xml_element_value "parameterDefinitions" <<< "$output" | grep -oP '(?<=<name>).*?(?=</name>)'))
param_values=($(get_xml_element_value "parameterDefinitions" <<< "$output" | grep -oP '(?<=<defaultValue>).*?(?=</defaultValue>)'))

write_file_path="$(ssh root@${INSTANCE_IP} -p ${INSTANCE_PORT} -i ~/mykeypair ls /var/lib/jenkins/jobs/tiny_web.imagebuild/workspace/jenkins-tiny_web.imagebuild* | tail -1)"
write_file="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${write_file_path}  2> /dev/null)"

while read line ; do
    param_is_set=false
    value_is_set=false

    saved_param="${line%=*}"
    saved_value="${line#*=}"

    [[ ${#param_names[@]} -eq ${#param_values[@]} ]] || return 1

    for (( i=0 ; i < ${#param_names[@]} ; i++ )) ; do
        [[ "$saved_param" == "${param_names[$i]}" ]] && param_is_set=true
        [[ "$saved_value" == "${param_values[$i]}" ]] && value_is_set=true
    done

    check_message $param_is_set "$saved_param is used as a build parameter"
    check_message $value_is_set "$saved_value is used as a value for $saved_param"

done <<< "$write_file"

