#!/bin/bash

[[ -f $(dirname $0)/pre-exec.sh ]] && . $(dirname $0)/pre-exec.sh

bash 2> /dev/null
