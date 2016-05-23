output="$(ssh -i /home/centos/mykeypair root@10.0.2.100 cat ${job_config} 2> /dev/null)"

test1_passed=false
test2_passed=false

check_param_value notificationType "SUCCESS STARTED FAILURE" <<< "$output" && test1_passed=true
$test1_passed && ! check_param_value notifyEnabled "false" "$output" <<< "$output" && test2_passed=true

check_message $test1_passed "$hipchat_notifications_status"
check_message $test2_passed "$hipchat_notifiyEnabled_status"
