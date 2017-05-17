output="$(ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${job_config} 2> /dev/null)"

test_passed=false

check_param_value childProjects "tiny_web.rpmbuild" <<< "$output" && test_passed=true
check_message $test_passed "Triggers tiny_web.rpmbuild"
