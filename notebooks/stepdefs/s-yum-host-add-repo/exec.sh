output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} '[[ -f /etc/yum.repos.d/example.repo ]]' 2> /dev/null)"

test_passed=$?
check_message $test_passed "/etc/yum.repos.d/example.repo exists"
