output="$(ssh -i ~/mykeypair root@10.0.2.100 grep command ${job_config} 2> /dev/null)"

[[ ! -z "$output" ]]
check_message $? "$add_build_script_status"
