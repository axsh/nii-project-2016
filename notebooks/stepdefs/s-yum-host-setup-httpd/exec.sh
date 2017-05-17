output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} 'service httpd status' 2> /dev/null)"

started_httpd=false

grep -q ^"httpd.*running" <<< "$output" && started_httpd=true

check_message $started_httpd "Started httpd"
