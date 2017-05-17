ssh -qi ~/mykeypair root@${INSTANCE_IP} "[[ -f \${HOME}/rpmbuild/RPMS/x86_64/example-0.1.0-1.el6.x86_64.rpm ]]" 2> /dev/null

passed=$?
check_message $passed "Created rpm"
