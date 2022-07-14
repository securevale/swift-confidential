#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2155

#####################
#     CONSTANTS     #
#####################

if [[ -t 1 && -t 2 ]]
then
    # shellcheck disable=SC2086
    function tput_set() { tput $1; }
else
    function tput_set() { :; }
fi

readonly BOLD=$(tput_set bold)
readonly UNDERLINE=$(tput_set smul)
readonly NORMAL=$(tput_set sgr0)

#####################
#     FUNCTIONS     #
#####################

function pushd_quiet() {
    pushd "$1" &>/dev/null || exit
}

function popd_quiet() {
    popd &>/dev/null || exit
}

function echoerr() {
    local IFS=" "
    cat <<< "$* ❌" 1>&2;
}

function echo_progress() {
    echo "$1 ⚙️"
}
