output="$(ssh -qi /home/centos/mykeypair root@10.0.2.100 cat ${job_config} 2> /dev/null | sed 's/&quot;/\"/g')"

task_passed=false

check_find_line_with "bundle" "exec" "rspec" "spec/webapi_integration_spec.rb" <<< "$output" && task_passed=true
check_message $task_passed "Executes integration test"
