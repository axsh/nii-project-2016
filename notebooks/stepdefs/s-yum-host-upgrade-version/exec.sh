output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} '[[ -f ${HOME}/rpmbuild/SOURCES/example-0.2.0.tar.gz ]]' 2> /dev/null)"

test_passed=$?
check_message $test_passed "Created example-0.2.0.tar.gz"
