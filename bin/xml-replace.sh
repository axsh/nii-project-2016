#!/bin/bash

targetfile="$1"
elementname="$2"
replacementtext="$3"

reportfailed()
{
    echo "Script failed...exiting. ($*)" 1>&2
    exit 255
}

[ -f "$targetfile" ] || reportfailed "XML file $1 not found"


pattern1="*<$elementname/>*"
pattern1b="*<$elementname>*</$elementname>*"
pattern2="*<$elementname*"
endpattern1="*</$elementname>*"

# Current Assumptions:
# - The target element only appears once.
# - Nothing unrelated to the target element appears on the same line as its markers.
#   (Because those lines get deleted entirely)
# - The elementname can not appear as the last line in the file, or else the
#   code will add a new line, whether one existed in the original file or not.

mv "$targetfile"  "$targetfile.org"
exec <"$targetfile.org"

replacedit=false
while IFS= read -r ln; do
    case "$ln" in
	$pattern1 | $pattern1b)
	    $replacedit && reportfailed "target element $elementname appeared twice"
	    # just replace this one line
	    printf "%s\n" "$replacementtext"
	    replacedit=true
	;;
	$pattern2)
	    $replacedit && reportfailed "target element $elementname appeared twice"
	    # scan until end pattern
	    foundit=false
	    while IFS= read -r ln; do
		[[ "$ln" == $endpattern1 ]] && foundit=true && break
	    done
	    $foundit || reportfailed "Matching </$elementname>" not found
	    # insert the rest here
	    printf "%s\n" "$replacementtext"
	    replacedit=true
	;;
	*)
	    printf "%s\n" "$ln"
	    ;;
    esac
    if $replacedit; then
	# we are using cat here to output the rest of the file, because
	# jenkins is sensitive to whether a newline appears at the end
	# of the file.  It is hard to make bash handle that case, so
	# let cat handle it and then exit.
	# (Therefore the "appeared twice" message above will never happen, BTW)
	cat
	break
    fi
done >"$targetfile"
