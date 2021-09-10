#!/usr/bin/env bash

set -eou pipefail

function _run_cmd {
  local regex='^\d+$'
  local cmd="$1"
  local timeout="$2"
  grep -Eqo "$regex" <<<"$timeout" || timeout=10

  (
    eval "$cmd" &
    child=$!
    trap -- "" SIGTERM
    (
      sleep $timeout
      kill $child
    ) >/dev/null 2>&1 &
    wait $child
  )
}

function _retry {
  local regex='^\d+$'
  local cmd=$1
  local timeout=$2
  local tries=$3
  local interval=$4
  grep -Eqo "$regex" <<<"$timeout" || timeout=10
  grep -Eqo "$regex" <<<"$tries" || tries=3
  grep -Eqo "$regex" <<<"$interval" || interval=3

  for ((count = 1; count <= tries; count++)); do
    _run_cmd "$cmd" "$timeout" && return
    sleep $interval
  done

  return 1
}
