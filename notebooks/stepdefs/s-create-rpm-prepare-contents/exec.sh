ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} "[[ -f \${HOME}/rpmbuild/SOURCES/example-0.1.0/bin/example ]]" 2> /dev/null

passed=$?
check_message $passed "Created example"
