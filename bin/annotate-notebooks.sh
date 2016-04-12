#!/bin/bash

# If this script is run without any parameters, it will make a copy of
# each notebook in an ./expanded/ directory, except that all headings
# will be expanded.  For some types of proof reading this is helpful.


export CODEDIR="$(cd "$(dirname "$0")" && pwd -P)"

if [ "$*" = "" ]; then
    cd "$CODEDIR/.."
    flist=( notebooks/*.ipynb )
else
    flist=( "$@" )
fi


process1()
{
    while IFS= read -r ln; do
	case "$ln" in
	    *hidden*:*true*)
		printf "%s\n" "${ln/hidden/hidevalue}"  # hide by renaming to unused value
		;;
	    *heading_collapsed*:*true*)
		printf "%s\n" "${ln/heading_collapsed/hidevalue}" # hide by renaming to unused value
		:
		;;
	    *)
		printf "%s\n" "$ln"
		;;
	esac
    done
}


for f in "${flist[@]}"; do
    full="$(readlink -f "$f")"
    fdir="$(dirname "$full")"
    fname="${full##*/}"
    mkdir -p "$fdir/expanded"
    process1 <"$f" >"$fdir/expanded/$fname"
done
