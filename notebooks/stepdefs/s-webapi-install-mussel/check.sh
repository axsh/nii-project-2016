#!/bin/bash
. ~/notebooks/stepdefs/jenkins-utility/message.conf
. ~/notebooks/stepdefs/jenkins-utility/check_message.sh

ssh -i ~/mykeypair root@10.0.2.100 "[[ -f /opt/axsh/wakame-vdc/client/mussel/bin/mussel ]] " 2> /dev/null

test_passed=$?
check_message $test_passed "Mussel installed"


