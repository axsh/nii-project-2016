output="$(ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${job_config} 2> /dev/null)"

test_passed=false

check_find_line_with "bundle" "exec" "rspec" "./spec/comment_spec.rb"  <<< "$output" && test_passed=true

check_message $test_passed "Unit tests gets executed"
