output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} '[[ -f /var/www/html/pub/x86_64/example-0.1.0-1.el6.x86_64.rpm ]]' 2> /dev/null)"

test_passed=$?
check_message $test_passed "RPM file published"
