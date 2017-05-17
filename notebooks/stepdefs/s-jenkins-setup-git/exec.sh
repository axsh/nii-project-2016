output="$(ssh -i ~/mykeypair root@10.0.2.100 cat ${filename} 2> /dev/null)"

test1_passed=false
test2_passed=false
test3_passed=false

check_plugins_exists "git" "git-client" && test1_passed=true
check_not_empty system_config "globalConfigName" <<< "$output" && test2_passed=true
check_not_empty system_config "globalConfigEmail" <<< "$output" && test3_passed=true

check_message $test1_passed "$plugin_installed_status"
check_message $test2_passed "$git_user_status"
check_message $test3_passed "$git_mail_status"
