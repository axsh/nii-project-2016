output="$(ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${job_config} 2> /dev/null)"

test1_passed=false
test2_passed=false
test3_passed=false

check_param_value projects "tiny_web.integration" <<< "$output" && test1_passed=true
check_param_value condition "SUCCESS" <<< "$output" && test2_passed=true
check_param_value propertiesFile "\${WORKSPACE}/\${BUILD_TAG}" <<< "$output" && test3_passed=true

check_message $test1_passed "Triggers tiny_web.integration"
check_message $test2_passed "Triggers on success only"
check_message $test3_passed "Saves parameters into \${WORKSPACE}/\${BUILD_TAG}"
