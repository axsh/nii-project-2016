output="$(ssh -i /home/centos/mykeypair root@10.0.2.100 cat ${job_config} 2> /dev/null)"

test_passed=false

check_not_empty "${output}" url <<< "$output" && test_passed=true

check_message $test_passed "$git_repo_status"
