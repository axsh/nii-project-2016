#!/bin/bash

filelist=( "$@" )
# for example, call like this:  ./safe-sync-files.sh notebooks/1*

cd "$(dirname $(readlink -f "$0"))" || exit 255
[ -f ./vmdir/ssh-to-kvm.sh ] || { echo "Could not find ./vmdir/ssh-to-kvm.sh." ; exit 255 ; }

doit_params="-avz -e ./vmdir/ssh-to-kvm.sh"
dryrun_params="$doit_params --dry-run -i"

# now send the day1 notebooks, but only if
# it does not create any files.
dryrunout="$(rsync $dryrun_params "${filelist[@]}" :./notebooks)"

# lines like "<f+++++++++ 101_HipChat_setup.ipynb" are files
# that would be copied in for the first time.  These are OK.
okfiltered="$(grep -vF '<f+++++++++' <<<"$dryrunout")"

# lines like "<f..t...... 101_HipChat_setup.ipynb" are files
# that would be overwritten.

notok="$(grep '^<' <<<"$okfiltered")"
if [ "$notok" != "" ]; then
    echo "Exiting without syncing notebooks because these notebooks would be overwritten:"
    echo "$notok"
    exit 255
fi

# seems safe, so sync to vm:
set -x
rsync $doit_params "${filelist[@]}" :./notebooks
