#!/bin/bash

. ~/notebooks/stepdefs/jenkins-utility/message.conf
. ~/notebooks/stepdefs/jenkins-utility/check_message.sh 

check-wakame.sh

test_passed=$?
check_message $test_passed "Instance terminated"
