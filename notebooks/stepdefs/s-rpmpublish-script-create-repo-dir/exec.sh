output="$(ssh -qi ~/mykeypair root@10.0.2.100 cat ${job_config} 2> /dev/null)"

repo_dir="/var/www/html/pub"

created=false
exists_check=false
found_public=false

# In case the directory is set as a variable get the variable name and
# make the checks in the cases where the variable might be used in place of
# the value.
found_line=$(get_line_with "=*$repo_dir" <<< "${output}")

if [[ $found_line == *=$repo_dir* ]] ; then
    # Consider cases where brackets are used during expansion
    repo_var[0]="\$${found_line%=*}"
    repo_var[1]="\${${found_line%=*}}"
fi

[[ ! -z $repo_var ]] && {
    for style in "${repo_var[@]}" ; do
        check_find_line_with "[ -d" "]" "$style" <<< "$output" && exists_check=true
        check_find_line_with "mkdir" "$style" <<< "$output" && found_public=true
    done
}

check_find_line_with "sudo" "mkdir" <<< "$output" && created=true
check_find_line_with "mkdir" "-p" <<< "$output" && exists_check=true
check_find_line_with "[ -d" "]" "$repo_dir" <<< "$output" && exists_check=true
check_find_line_with "mkdir" "$repo_dir" <<< "$output" && found_public=true


check_message $created "Directory gets created"
check_message $found_public "Directory is created at /var/www/html/pub"
check_message $exists_check "Checks if directory exsist"
