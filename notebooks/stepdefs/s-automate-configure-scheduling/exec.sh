output="$(ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${job_config} 2> /dev/null)"

test_passed=false

check_param_value spec "5$sp*$sp*$sp*$sp*" <<< "$output" && test_passed=true
check_message $test_passed "Polling configured"
