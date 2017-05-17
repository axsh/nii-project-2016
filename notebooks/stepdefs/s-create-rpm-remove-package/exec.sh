output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} 'rpm -qa' 2> /dev/null)"

test_passed=false

grep -q ^"example" <<< "$output" || test_passed=true
check_message $test_passed "Example removed"
