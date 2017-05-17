output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} 'rpm -qi example' 2> /dev/null)"

[[ "$output" == *0.2.0* ]]
test_passed=$?
check_message $test_passed "Version 2 of RPM file installed"
