#!/usr/bin/env bash

set -eou pipefail

source "$(dirname "${0}")/utils.sh"

_ip="${1}"

_check_health() {
  local address="${1}:8080/healthz"

  echo "checking health at ${address}..."
  curl --fail "${address}" >/dev/null
}

_run_health_checks() {
  local timeout=5
  local tries=60
  local interval=2

  _retry "_check_health ${1}" "$timeout" "$tries" "$interval"
}

if _run_health_checks "${_ip}"; then
  echo "health check succeeded for ${_ip}"
else
  echo "health check timed out for ${_ip}" && exit 1
fi
