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

  function validate_var_exists() {
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

  function terraform_write_variables() {
    local variables=(
      DIGITALOCEAN_ACCESS_TOKEN
    )
    local file="${1}"

    log "Setting Terraform variables in ${file}\n"

    for variable in "${variables[@]}"; do
      validate_var_exists "${variable}"
      system_sed "s/${variable}/${!variable}/" "${file}"
    done
  }

  function terraform_prepare_variables() {
    log "Preparing Terraform variables\n"

    local terraform_file=terraform.tfvars

    cp -v terraform.tfvars.example "${terraform_file}"

    terraform_write_variables "${terraform_file}"
  }

  function terraform_prepare() {
    terraform_prepare_variables
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
    local deployment_type
    deployment_type="$(terraform output -json | jq '.last_deployment_type.value')"

    if [ -z "${deployment_type}" ]; then
      deployment_type="blue"
    fi

    # remove quotes
    deployment_type=$(echo "${deployment_type}" | tr -d \" | tr -d \')

    echo "${deployment_type}"
  }

  function deploy() {
    local last_deploy_exit_code="${1}"
    local last_deployment_type
    local transition_state
    local plan_file=.terraform.plan
    last_deployment_type=$(get_last_deployment_type)
    transition_state=$(get_transition_state "${last_deploy_exit_code}")
    system_state="${last_deployment_type}.${transition_state}"

    terraform plan -out="${plan_file}" >/dev/null

    case "${system_state}" in
    # if blue, transition to green
    blue.initial)
      log "Transitioning from blue to transition_to_green"
      terraform apply -auto-approve -var deployment_type=transition_to_green
      deploy "$?"
      ;;

    # if green, transition to blue
    green.initial)
      log "Transitioning from green to transition_to_blue"
      terraform apply -auto-approve -var deployment_type=transition_to_blue
      deploy "$?"
      ;;

    # if transitioning to green, complete transition
    transition_to_green.initial | transition_to_green.success)
      log "Transitioning from transition_to_green to green"
      terraform apply -auto-approve -var deployment_type=green
      deploy "$?"
      ;;

    # if transitioning to blue, complete transition
    transition_to_blue.initial | transition_to_blue.success)
      log "Transitioning from transition_to_blue to blue"
      terraform apply -auto-approve -var deployment_type=blue
      deploy "$?"
      ;;

    # if failed during transition to blue, go back to green
    transition_to_blue.failure)
      log "Failure transitioning to blue; transitioning back to green"
      terraform apply -auto-approve -var deployment_type=green
      deploy "$?"
      ;;

    # if failed during transition to green, go back to blue
    transition_to_green.failure)
      log "Failure transitioning to green; transitioning back to blue"
      terraform apply -auto-approve -var deployment_type=blue
      deploy "$?"
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
      error "Unable to transition"
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
  deploy
}

__main "$*"
