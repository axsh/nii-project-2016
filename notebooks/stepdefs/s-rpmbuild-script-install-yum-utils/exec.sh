output="$(ssh -qi ~/mykeypair root@10.0.2.100 cat ${job_config} 2> /dev/null)"

test_passed=false

check_find_line_with "sudo" "yum" "install" "yum-utils" <<< "$output" && test_passed=true

check_message $test_passed "Yum utils gets installed"
