#!/usr/bin/env bash

set -eou pipefail

_healthcheck_path='.loadbalancer_healthcheck.value[0][0]'

_get_loadbalancer_prop() {
  local value
  value=$(terraform output -json | jq "${_healthcheck_path}.${1}")

  echo "${value}"
}

_loadbalancer_timeout() {
  local interval=10
  local healthy_threshold=5
  interval=$(_get_loadbalancer_prop "check_interval_seconds")
  healthy_threshold=$(_get_loadbalancer_prop "healthy_threshold")
  local timeout="$((interval * healthy_threshold))"

  echo "waiting ${timeout}s for healthy droplet in load balancer..."
  sleep "${timeout}"
}

_loadbalancer_timeout
