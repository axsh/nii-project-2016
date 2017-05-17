#!/bin/bash

source ~/notebooks/stepdefs/jenkins-utility/message.conf
source ~/notebooks/stepdefs/jenkins-utility/check_message.sh

out="$(ssh -qi ~/mykeypair root@10.0.2.100 'grep requiretty /etc/sudoers' 2>&1)"

out2="$(echo "$out" | grep -v '^ *#')"

# so out2 is now "lines with requiretty that do not begin with a comment character"

[ "$out2" = "" ]
test_passed="$?"

check_message $test_passed "Configured tty"
