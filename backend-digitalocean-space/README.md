# Digitalocean / Terraform blue-green zero-downtime deployment

This repo demonstrates how to perform blue-green deployments on Digitalocean using
Terraform.

## Why

This example demonstrates how to use Digitalocean's spaces as a remote backend
for storing tfstate.

## Instructions

1. Install Terraform on your machine
1. Configure Digitalocean personal access token:
    1. Create a token in Digitalocean
    1. Make it available to Terraform on your local machine:

        ```bash
        $ export DIGITALOCEAN_ACCESS_TOKEN=your-access-token
        ```
1. Configure Digitalocean space token and secret:
    1. Create a token in Digitalocean's spaces UI
    1. Make the token and secret available to the command line

        ```bash
        $ export DO_SPACES_ACCESS_TOKEN=your-space-access-token
        $ export DO_SPACES_SECRET=your-space-secret-key
        ```
1. Initialise Terraform:

    ```bash
    $ terraform init
    ```
1. View the plan

    ```bash
    $ terraform plan
    ```
1. Initialise the blue droplets

    ```bash
    $ terraform apply -auto-approve -var state=blue
    ```
1. Initialise the blue droplets

    ```bash
    $ terraform apply -auto-approve -var state=blue
    ```
1. Initialise the transition

    ```bash
    $ terraform apply -auto-approve -var state=transition_to_green
    ```
1. Visit the loadbalancer IP address, reloading to see the load being routed
   between your droplets

    ```bash
    $ ssh app@$(terraform output -json ip_address | jq -r '.[0]') -i my-key
    $ exit
    ```
1. Finalise the transition to green

    ```bash
    $ terraform apply -auto-approve -var state=green
    ```
1. Clean up

    ```bash
    $ terraform destroy -auto-approve
    ```
