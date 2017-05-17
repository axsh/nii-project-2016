. ~/notebooks/stepdefs/jenkins-utility/xml-utility.sh

output="$(ssh -qi ~/mykeypair root@10.0.2.100 cat ${job_config} 2> /dev/null | sed 's/&quot;/\"/g')"

param_names=($(get_xml_element_value "parameterDefinitions" <<< "$output" | grep -oP '(?<=<name>).*?(?=</name>)'))

# Currently this check makes sure that the parameters saved from tiny_web.imagebuild job gets assigned
# This check does not check wether the varaibles are assigned the correct value
# because the variable name it self is unknown.
# 
# Improvement will required backtracking through the jenkins log files for tiny_web.imagebuild
# to get the ids as they are generated by our provided scripts

for param in ${param_names[@]} ; do
    variable_is_defined=false

    line=$(get_line_with "=\$$param" <<< "$output")
    [[ -z $line ]] && { line=$(get_line_with "=\"\$$param\"" <<< "$output") ; }
    [[ -z $line ]] && { line=$(get_line_with "=\${$param}" <<< "$output") ; }
    [[ -z $line ]] && { line=$(get_line_with "=\"\${$param}\"" <<< "$output") ; }
    var_name=${line%=*}
    
    [[ -z $var_name ]] && { var_name="Undefined" ;} || {
        check_find_line_with "=\$$param" <<< "$output" && variable_is_defined=true
        check_find_line_with "=\"\$$param\"" <<< "$output" && variable_is_defined=true
        check_find_line_with "=\${$param}" <<< "$output" && variable_is_defined=true
        check_find_line_with "=\"\${$param}\"" <<< "$output" && variable_is_defined=true
    }

    check_message $variable_is_defined "Parameter: $param value is defined to variable: $var_name"
done
