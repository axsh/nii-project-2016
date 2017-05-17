output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} 'rpm -qa' 2> /dev/null)"

installed_createrepo=false
installed_httpd=false

grep -q ^"createrepo" <<< "$output" && installed_createrepo=true
grep -q ^"httpd" <<< "$output" && installed_httpd=true

check_message $installed_createrepo "Found createrepo"
check_message $installed_httpd "Found httpd"
