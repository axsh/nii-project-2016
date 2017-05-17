output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} '[[ -d /var/www/html/pub ]]' 2> /dev/null)"

test_passed=$?
check_message $test_passed "Created public folder for httpd"
