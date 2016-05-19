#!/bin/bash

direction="$1" # tovm or fromvm
dirname="$2" # notebooks or bin

# there is also a $rsyncextra parameter that can be
# set to stuff like: rsyncextra='--dry-run'

: "${dirname:=notebooks}"

set -e
cd "$(dirname $(readlink -f "$0"))"
[ -f ./vmdir/ssh-to-kvm.sh ] || { echo "Could not find ./vmdir/ssh-to-kvm.sh." ; exit 255 ; }

case "$1" in
    tovm)
	./vmdir/ssh-to-kvm.sh mkdir -p "$dirname" # does not seem to be a way to do this with rsync
	rsync -avz -e ./vmdir/ssh-to-kvm.sh $rsyncextra ./"$dirname"/ :/home/centos/"$dirname"
	;;
    fromvm)
	mkdir -p "$dirname" # does not seem to be a way to do this with rsync
	rsync -avz -e ./vmdir/ssh-to-kvm.sh $rsyncextra :/home/centos/"$dirname"/ ./"$dirname"
	;;
    *) echo "First parameter should be tovm or fromvm"
       ;;
esac
