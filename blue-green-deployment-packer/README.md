# Digitalocean / Terraform blue-green zero-downtime deployments using Packer

This repo demonstrates how to perform blue-green deployments on Digitalocean using
Terraform.

## Why

To determine whether using Packer to build machine images is more efficient than
requiring each droplet to pull Docker images on each deploy.

This example contrasts with the strategy of pulling Docker images during the
provisioningin of droplets in the [blue-green deployments
example](../blue-green-deployment).

## Instructions

1. Install Terraform and Packer on your machine
1. Configure Digitalocean personal access token:
    1. Create a token in Digitalocean
    1. Make it available to Terraform on your local machine:

        ```bash
        $ export DIGITALOCEAN_ACCESS_TOKEN=your-access-token
        ```
1. Configure a local SSH key
    1. Create a key without a passphrase

        ```bash
        $ ssh-keygen -t rsa -f ./my-key
        ```
    2. Copy your public key to your clipboard

        ```bash
        $ cat my-key.pub | pbcopy
        ```
    3. Update the name of your public key if it's not `my-key` in
       [`variables.tf`](./variables.tf):

        ```hcl
        variable "ssh_key" {
            # ...
            default = {
                # ...
                public_key_file = "[your-key].pub"
            }
        }
        ```
1. Generate certificates for the load balancer:
    ```shell
    $ ./scripts/generate-certificate.sh
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
