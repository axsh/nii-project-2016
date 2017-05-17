output="$(ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} cat ${filename} 2> /dev/null)"

test1_passed=false
test2_passed=false
test3_passed=false

check_plugins_exists "hipchat" && test1_passed=true
check_not_empty system_config "token" <<< "$output" && test2_passed=true
check_not_empty system_config "room" <<< "$output" && test3_passed=true

check_message $test1_passed "$plugin_installed_status"
check_message $test2_passed "$hipchat_token_status"
check_message $test3_passed "$hipchat_room_status"
