output="$(ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} grep command ${job_config} 2> /dev/null)"

[[ ! -z "$output" ]]
check_message $? "$add_build_script_status"
