ssh -i ~/mykeypair root@10.0.2.100 "[[ -d /var/lib/jenkins/jobs/${job} ]]" 2> /dev/null

test_passed=$?
check_message $test_passed "$create_job_status"
