output="$(ssh -i ~/mykeypair root@${INSTANCE_IP} cat ${job_config} 2> /dev/null)"

test_passed=false

check_not_empty "${output}" url <<< "$output" && test_passed=true

check_message $test_passed "$git_repo_status"
