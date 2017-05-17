output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} '[[ -f /root/rpmbuild/RPMS/x86_64/example-0.2.0-1.el6.x86_64.rpm ]]' 2> /dev/null)"

test_passed=$?
check_message $test_passed "Version 2 of RPM file exists"
