#!/bin/bash

. $(dirname $0)/stepdata.conf

scp -i ~/mykeypair root@10.0.2.100:"$filename" $(dirname $0)/xml-data/ &> /dev/null
