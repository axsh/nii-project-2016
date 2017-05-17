#!/bin/bash

. $(dirname $0)/stepdata.conf

[[ -f $(dirname $0)/xml-data/"${filename##*/}" ]] &&
    scp -i ~/mykeypair $(dirname $0)/xml-data/"${filename##*/}"  root@10.0.2.100:"$filename"
