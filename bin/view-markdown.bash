#!/bin/bash

# Requires apt package 'python3-rich'

set -ue

PATH=/usr/bin:/bin
_f="${1:-x}"

if ! grep -iq '\.md$' <<<"${_f}" ; then
        printf '%s\n' "usage: ${0} some-file.md" >&2
        exit 1
fi

if [ ! -f "${_f}" ] || [ ! -r "${_f}" ] ; then
        printf '%s\n' "Cannot read ${_f}" >&2
        exit 1
fi

python3 -m rich.markdown "${_f}"
