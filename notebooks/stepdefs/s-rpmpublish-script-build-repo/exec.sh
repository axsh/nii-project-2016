output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${job_config} 2> /dev/null)"

repo_dir="/var/www/html/pub"
found_line=$(get_line_with "=*$repo_dir" <<< "${output}")

if [[ $found_line == *=$repo_dir* ]] ; then
    # Consider cases where brackets are used during expansion
    repo_var[0]="\$${found_line%=*}"
    repo_var[1]="\${${found_line%=*}}"
fi

changed=false
created=false

check_find_line_with "cd" "$repo_dir" <<< "$output" && changed=true
check_find_line_with "sudo" "createrepo" "$repo_dir" <<< "$output" && created=true
$changed && { check_find_line_with "sudo" "createrepo" "." <<< "$output" && created=true ; }

[[ ! -z $repo_var ]] && {
    for style in "${repo_var[@]}" ; do
        check_find_line_with "cd" "$style" <<< "$output" && changed=true
        check_find_line_with "createrepo" "$style" "sudo" <<< "$output" && created=true
        $changed && { check_find_line_with "sudo" "createrepo" "." <<< "$output" && created=true ; }
    done
}


check_message $created "Repository gets created at /var/www/html/pub"
