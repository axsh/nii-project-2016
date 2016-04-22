#!/bin/bash

### colors

original='\033[0m'
red='\033[00;31m'
green='\033[00;32m'

CHECK_MARK="[${green}\xE2\x9C\x93${original}]"
CROSS_MARK="[${red}\xE2\x9C\x97${original}]"

function pretty_message() {
    local format_mode=${1} ; shift
    local passed=${1} ; shift
    local message task="${1}"

    case "${format_mode}_${passed}" in
        0*passed) message="${green}${default_pass_message}${original}" ;;
        0*failed) message="${red}${default_fail_message}${original}" ;;

        1*passed) message="$CHECK_MARK ${task}" ;;
        1*failed) message="$CROSS_MARK ${task}" ;;

        2*passed) message="${task} [ ${green}OK${original} ]" ;;
        2*failed) message="${task} [ ${green}FAILED${original} ]" ;;
    esac
    echo -e "$message"
}

function check_message() {
    local passed=${1} task="${2:-$default_pass_message}"

    # Optional variables incase different styles is desired for pass and fail message
    local output_mode_pass="${output_modep_pass:-$output_mode}"
    local output_mode_fail="${output_mode_fail:-$output_mode}"

    case ${passed} in
        0 | true)
            pretty_message $output_mode_pass passed "${task}" ;;
        1 | false)
            pretty_message $output_mode_fail failed "${task}" ;;
    esac
}
