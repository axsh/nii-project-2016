ssh -i ~/mykeypair root@${INSTANCE_IP} "[[ -d /var/lib/jenkins/jobs/${job} ]]" 2> /dev/null

test_passed=$?
check_message $test_passed "$create_job_status"
