#! /usr/bin/env bash
# This script:
#   - copies terraform.tfvars for the given environment
#   - replaces values in terraform.tfvars with those in the environment
#   - determines from the remote Terraform deployment_type which deployment_type
#     to transition to (blue/green)
#   - validates the Terraform config
#   - transitions the Terraform deployment_type between blue and green
# Requirements:
#   - jq
#   - terraform
# Environment variables:
#   - DOCEAN_ACCESS_TOKEN   - Digitalocean personal access token
# Example usage:
#   ./deploy.sh [staging|production]

set -eo pipefail

function __main() {
  function log() {
    echo -e "[$(printf "%(%F-%H-%M-%S)T\n")]: $*"
  }

  function error() {
    echo -e "[ERROR]: $*"
  }

  function assert_env_var_exists() {
    local name="${1}"

    if [ -z "${!name}" ]; then
      error "${name} env var not set"
      exit 1
    fi
  }

  function system_sed() {
    if [ "$(uname)" == "Darwin" ]; then
      sed -I '.bak' "$@"
    else
      sed --in-place "$@"
    fi
  }

  function terraform_validate() {
    log "Validating Terraform configs\n"
    terraform validate
  }

  function terraform_write_tfvars() {
    local names=(
      DIGITALOCEAN_ACCESS_TOKEN
    )
    local file="${1}"

    log "Setting Terraform variables in ${file}\n"

    for name in "${names[@]}"; do
      local delimiter="/"

      # Use | as a delimiter for sed if the value contains /
      # If the value also contains |, this will function will still fail
      if [[ "${!name}" =~ "/" ]]; then
        delimiter="|"
      fi

      assert_env_var_exists "${name}"
      system_sed "s${delimiter}${name}${delimiter}${!name}${delimiter}" "${file}"
    done
  }

  function terraform_prepare_tfvars() {
    log "Preparing Terraform variables\n"

    local var_files=(
      terraform.tfvars
    )

    for var_file in "${var_files[@]}"; do
      cp -v "${var_file}.example" "${var_file}"
      terraform_write_tfvars "${var_file}"
    done
  }

  function terraform_prepare() {
    terraform_prepare_tfvars
    terraform init -backend-config=backend.tfvars
  }

  function get_transition_state() {
    local last_deploy_exit_code="${1:--1}"
    local transition_state=initial

    case "${last_deploy_exit_code}" in
    -1)
      transition_state=initial
      ;;
    0)
      transition_state=success
      ;;
    *)
      transition_state=failure
      ;;
    esac

    echo "${transition_state}"
  }

  function get_last_deployment_type() {
    local deployment_type="null"
    # jq returns `null` if unable to match on a property
    deployment_type=$(terraform output -json | jq '.last_deployment_type.value')

    if [ "${deployment_type}" == "null" ]; then
      deployment_type="blue"
    fi

    # remove quotes
    deployment_type=$(echo "${deployment_type}" | tr -d \"\')

    echo "${deployment_type}"
  }

  function run_deploy() {
    local deployment_type="${1}"

    terraform plan

    # shellcheck disable=SC2015
    terraform apply -auto-approve -var deployment_type="${deployment_type}" &&
      # always run try_deploy whether `terraform apply` fails or succeeds
      # - try_deploy will roll back if a transition_to deployment fails
      try_deploy "$?" || try_deploy "$?"
  }

  function try_deploy() {
    local last_deploy_exit_code="${1}"
    local last_deployment_type
    local transition_state
    local system_state
    last_deployment_type=$(get_last_deployment_type)
    transition_state=$(get_transition_state "${last_deploy_exit_code}")
    system_state="${last_deployment_type}.${transition_state}"

    function handle() {
      echo "handled ${1}"
    }

    case "${system_state}" in
    # if blue, transition to green
    blue.initial)
      log "Transitioning from blue to transition_to_green"
      run_deploy transition_to_green
      ;;

    # if green, transition to blue
    green.initial)
      log "Transitioning from green to transition_to_blue"
      run_deploy transition_to_blue
      ;;

    # if transitioning to green, complete transition
    transition_to_green.initial | transition_to_green.success)
      log "Transitioning from transition_to_green to green"
      run_deploy green
      ;;

    # if transitioning to blue, complete transition
    transition_to_blue.initial | transition_to_blue.success)
      log "Transitioning from transition_to_blue to blue"
      run_deploy blue
      ;;

    # if failed during transition to blue, go back to green
    transition_to_blue.failure)
      log "Failure transitioning to blue; transitioning back to green"
      run_deploy green
      ;;

    # if failed during transition to green, go back to blue
    transition_to_green.failure)
      log "Failure transitioning to green; transitioning back to blue"
      run_deploy blue
      ;;

    # if green or blue success, we're done
    blue.success | green.success)
      log "Successfully deployed ${deployment_type}"
      ;;

    # if green or blue failed, manual intervention required
    blue.failure | green.failure)
      error "Deployment ${deployment_type} failed"
      exit 1
      ;;

    *)
      error "Unable to transition ${system_state}"
      exit 1
      ;;
    esac
  }

  local environment="${1:-staging}"
  local script_dir
  script_dir=$(dirname "${0}")

  # the Terraform directory relative to this script
  local terraform_dir
  local terraform_path
  terraform_dir="${script_dir}/.."
  terraform_path=$(realpath "${terraform_dir}")

  log "Running Terraform from the following directory:\n${terraform_path}"
  cd "${terraform_path}"

  terraform_prepare
  terraform_validate
  try_deploy

}

__main "$*"
