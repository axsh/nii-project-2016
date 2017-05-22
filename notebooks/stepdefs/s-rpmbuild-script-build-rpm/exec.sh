output="$(ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${job_config} 2> /dev/null)"

test_passed=false
line=$(RETURN_LINE=true check_find_line_with "rpmbuild" "-bb" "./rpmbuild/SPECS/tiny-web-example.spec" <<< "$output")
[[ $? == 0 ]] && {
     [[ "${line}" =~ ^"rpmbuild" ]] && test_passed=true
}

check_message $test_passed "Rpm gets built"
