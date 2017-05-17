output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} '[[ -d /var/www/html/pub/repodata ]]' 2> /dev/null)"

test_passed=$?
check_message $test_passed "/var/www/html/pub/repodata exists"
# this currently checks existance of repodata.
# TODO: find commands to tell that version 2 was added
