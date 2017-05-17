output="$(ssh -qi ~/mykeypair root@10.0.2.100 cat ${job_config} 2> /dev/null)"

repo_dir="/var/www/html/pub"
found_line=$(get_line_with "=*$repo_dir" <<< "${output}")

if [[ $found_line == *=$repo_dir* ]] ; then
    # Consider cases where brackets are used during expansion
    repo_var[0]="\$${found_line%=*}"
    repo_var[1]="\${${found_line%=*}}"
fi

changed=false
synched=false

check_find_line_with "cd" "\${HOME}/rpmbuild/RPMS" <<< "$output" && changed=true
check_find_line_with "rsync" "sudo" "\${HOME}/rpmbuild/RPMS" "-avx" "$repo_dir" <<< "$output" && synched=true
$changed && { check_find_line_with "rsync" "sudo" "-avx" "$repo_dir" <<< "$output" && synched=true ; }

[[ ! -z $repo_var ]] && {
    for style in "${repo_var[@]}" ; do
        check_find_line_with "rsync" "sudo" "\${HOME}/rpmbuild/RPMS" "-avx" "$style" <<< "$output" && synched=true
        $changed && { check_find_line_with "rsync" "sudo" "-avx" "$style" <<< "$output" && synched=true ; }
    done
}

check_message $synched "\${HOME}/rpmbuils/RPMS gets synchronized with /var/www/html/pub"
