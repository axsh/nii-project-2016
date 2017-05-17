output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} 'rpm -qa' 2> /dev/null)"

installed_example=false

grep -q ^"example" <<< "$output" && installed_example=true

check_message $installed_example "Example package was installed"

