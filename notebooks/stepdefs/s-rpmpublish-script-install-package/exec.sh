output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${job_config} 2> /dev/null)"

test1_passed=false
test2_passed=false

{
    check_find_line_with "sudo" "yum" "install" "httpd" && test1_passed=true
    check_find_line_with "sudo" "/etc/init.d/httpd" "start" && test2_passed=true
    check_find_line_with "sudo" "service" "httpd" "start" && test2_passed=true
} <<< "${output}"

check_message $test1_passed "httpd gets installed"
check_message $test2_passed "httpd service gets started"
