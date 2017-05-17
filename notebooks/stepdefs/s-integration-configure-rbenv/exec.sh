output="$(ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${job_config} 2> /dev/null)"

test1_passed=false
test2_passed=false

check_find_line_with "version" "2.0.0-p598" <<< "$output" && test1_passed=true
check_find_line_with "gem__list" "bundler" "rake" <<< "$output" && test2_passed=true

check_message $test1_passed "$rbenv_version_status"
check_message $test2_passed "$rbenv_gems_status"
