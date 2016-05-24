output="$(ssh -i /home/centos/mykeypair root@10.0.2.100 cat ${job_config} 2> /dev/null)"

test1_passed=false
test2_passed=false

check_param_value childProjects "tiny_web.rpmbuild" <<< "$output" && test1_passed=true
check_param_value spec "0$sp*$sp*$sp*$sp*" <<< "$output" && test2_passed=true

check_message $test1_passed "Triggers tiny_web.rpmbuild"
check_message $test2_passed "Polling configured"
