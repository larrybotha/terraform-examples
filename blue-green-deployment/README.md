# Digitalocean / Terraform blue-green zero-downtime deployment

This repo demonstrates how to perform blue-green deployments on Digitalocean using
Terraform.

## Why

This is not trivial, despite how many examples I've come across!

This example has the following features:

- provisions the following resources on Digitalocean:
    - SSH key
    - loadbalancer, configured to route by droplet tags
        - this reduces the time for droplets to become healthy, since as soon as
            droplets are deployed with a tag, they will be added to a load
            balancer. Adding droplets via id can take longer, since we first
            need to check that a droplet is itself healthy, and then only may it
            be added to a loadbalancer. Instead, we assume that the droplet is
            going to become healthy, and let the loadbalancer deal with routing
            traffic
    - droplets
- when transitioning from blue to green, or vice versa:
    - builds new droplets
    - makes no changes to existing droplets
- when finalising a deployment
    - destroys old droplets

## Instructions

1. Install Terraform on your machine
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
