output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} 'rpm -qa' 2> /dev/null)"

installed_git=false
installed_rpmbuild=false
installed_rpmlint=false

grep -q ^"git" <<< "$output" && installed_git=true
grep -q ^"rpm-build" <<< "$output" && installed_rpmbuild=true
grep -q ^"rpmlint" <<< "$output" && installed_rpmlint=true

check_message $installed_git "Found Git"
check_message $installed_rpmbuild "Found rpm-build"
check_message $installed_rpmlint "Found rpmlint"
