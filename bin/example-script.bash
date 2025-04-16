#!/bin/bash

# Arbitrary bash script designed to win, not self-sabotage.
#
# Written by ecs-hk.
#
# Licensed under:
# Apache License, Version 2.0 (http://apache.org/licenses/LICENSE-2.0).

# --------------------------------------------------------------------------- #
#                       SHELL OPTIONS
# --------------------------------------------------------------------------- #

set -u
set -o pipefail

# --------------------------------------------------------------------------- #
#                       VARIABLE DEFINITIONS
# --------------------------------------------------------------------------- #

PATH=/usr/bin:/bin:/usr/local/bin:/usr/games

readonly _output_d="$(mktemp -d -p /tmp ${0##*/}.XXXXXX)"
readonly _log="${_output_d}/log.txt"
readonly _api_res="${_output_d}/api-response-body.json"

readonly _api_uri='https://api.chucknorris.io/jokes/random'

# --------------------------------------------------------------------------- #
#                       HELPER FUNCTIONS
# --------------------------------------------------------------------------- #

errout() {
        readonly _err_msg="${0##*/} error: ${1} (see ${_log})"
        printf '%s\n' "${_err_msg}" >&2
        exit 1
}

cleanup() {
        # If the script reported no error, clean up the output directory.
        if [ "${_err_msg:-x}" == "x" ] ; then
                rm -fr "${_output_d}"
        fi
}

print_usage_and_exit() {
        printf '%s\n' "Usage: ${0##*/} -n NAME -x joke|fortune [-d]"
        exit 1
}

print_debug() {
        local _msg="${1:-x}"
        local _data_f="${2:-x}"

        if [ "${_debug:-x}" != "debug" ] ; then
                return
        fi

        printf '%s\n' "${_msg}"

        if [ -e "${_data_f}" ] ; then
                cat "${_data_f}"
                printf '\n\n'
        fi
}

audit_basics() {
        local _i

        for _i in curl jq fortune cowsay ; do
                which "${_i}" > /dev/null 2>&1

                if [ ${?} -ne 0 ] ; then
                        errout "${_i} not found in PATH"
                fi
        done
}

get_cli_args() {
        # NB: colon (:) indicates that the preceding letter option takes an
        # argument, and causes $OPTARG to be filled with the argument value.
        while getopts 'h?n:x:d' opt ; do
                case "${opt}" in
                'h|?')  print_usage_and_exit
                        ;;
                'n')    readonly _name="${OPTARG:-x}"
                        ;;
                'x')    readonly _run_mode="${OPTARG:-x}"
                        ;;
                'd')    readonly _debug="debug"
                        ;;
                esac
        done
}

audit_cli_args() {
        if [ "${_name:-x}" == "x" ] ; then
                print_usage_and_exit
        fi

        if [ "${_run_mode:-x}" == "joke" ] ; then
                :
        elif [ "${_run_mode:-x}" == "fortune" ] ; then
                :
        else
                print_usage_and_exit
        fi
}

# --------------------------------------------------------------------------- #
#                       FUNCTIONS
# --------------------------------------------------------------------------- #

call_api() {
        print_debug "HTTP GET ${_api_res}"

        curl -X GET                                                     \
        -sS                                                             \
        -f                                                              \
        -H 'Accept: application/json'                                   \
        -o "${_api_res}"                                                \
        "${_api_uri}"

        if [ ${?} -ne 0 ] ; then
                errout 'Problem calling API'
        fi

        print_debug "HTTP response body:" "${_api_res}"
}

fill_message_from_api_res() {
        print_debug 'Determining message based on API response'

        readonly _message="$(jq -r '.value' ${_api_res})"

        if [ "${_message:-x}" == "x" ] ; then
                errout "Unknown API response"
        fi
}

fill_message_from_cmd() {
        print_debug 'Determining message based on fortune(6) command'

        readonly _message="$(fortune -s)"

        if [ "${_message:-x}" == "x" ] ; then
                errout "Problem with fortune output"
        fi
}

# --------------------------------------------------------------------------- #
#                       SIGNAL HANDLING
# --------------------------------------------------------------------------- #

trap 'cleanup' EXIT
trap 'exit 2' HUP INT QUIT TERM

# --------------------------------------------------------------------------- #
#                       MAIN LOGIC
# --------------------------------------------------------------------------- #

audit_basics
get_cli_args "${@:-x}"
audit_cli_args

printf '%s\n\n' "Hello, ${_name}. Some words of wisdom to consider.."

if [ "${_run_mode:-x}" == "joke" ] ; then
        call_api
        fill_message_from_api_res
else
        fill_message_from_cmd
fi

cowsay "${_message}"

exit 0
