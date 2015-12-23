#!/bin/bash

reportfailed()		      
{
    echo "Script failed...exiting. ($*)" 1>&2
    exit 255
}

export ORGCODEDIR="$(cd "$(dirname $(readlink -f "$0"))" && pwd -P)" || reportfailed
export SYMLINKDIR="$(cd "$(dirname "$0")" && pwd -P)" || reportfailed

if [ "$DATADIR" = "" ]; then
    # Choose directory of symbolic link by default
    DATADIR="$SYMLINKDIR"
fi
source "$ORGCODEDIR/../simple-defaults-for-bashsteps.source"

kvm_is_running()
{
    kvmpid="$(cat "$DATADIR/runinfo/kvm.pid" 2>/dev/null)" &&
	[ -d /proc/"$(< "$DATADIR/runinfo/kvm.pid")" ]
}

(
    $starting_checks 'Send "sudo shutdown -h now" via ssh'
    false
    $skip_rest_if_already_done ; set -e
    "$DATADIR/ssh-to-kvm.sh" sudo shutdown -h now
) ; prev_cmd_failed

: ${WAITFORSHUTDOWN:=2 2 2 2 2 5 10 20 30 60} # set WAITFORSHUTDOWN to "0" to not wait
(
    $starting_checks "Wait for KVM to exit"
    [ "$WAITFORSHUTDOWN" = "0" ] || ! kvm_is_running
    $skip_rest_if_already_done
    WAITFORSHUTDOWN="${WAITFORSHUTDOWN/[^0-9 ]/}" # make sure its only a list of integers
    waitfor="5"
    while true; do
	kvm_is_running || break # sets $kvmpid
	# Note that the </dev/null above is necessary so nc does not
	# eat the input for the next line
	read -d ' ' nextwait # read from list
	[ "$nextwait" == "0" ] && reportfailed "KVM process did not exit"
	[ "$nextwait" != "" ] && waitfor="$nextwait"
	echo "Waiting for $waitfor seconds for KVM process $kvmpid to exit"
	sleep "$waitfor"
    done <<<"$WAITFORSHUTDOWN"
) ; prev_cmd_failed
