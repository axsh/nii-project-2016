output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} '[[ -f ${HOME}/rpmbuild/SPECS/example.spec ]]' 2> /dev/null)"

test_passed=$?
check_message $test_passed "Created example.spec"
