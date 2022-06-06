#!/bin/bash
# This script:
#   - generates a public / private key pair
# Requirements:
#   - bash
#   - openssl
# Example usage:
#   ./gen-keys.sh.sh

function __main() {
  local dir=./
  local private_file="${dir}/my-key.cloudfront_private.pem"
  local public_file="${dir}/my-key.cloudfront_public.pem"

  openssl genrsa -out "${private_file}" 2048
  openssl rsa -pubout -in "${private_file}" -out "${public_file}"
}

__main "$*"
