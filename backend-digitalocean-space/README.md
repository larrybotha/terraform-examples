# Terraform with Digitalocean space as a remote backend

This repo demonstrates how to use Digitalocean as a remote backend for Terraform.

## Instructions

1. Install Terraform on your machine
1. Create a token in Digitalocean
1. Create a space token and secret in Digitalocean
1. Add your credentials to a variables file:
    ```shell
    # terraform.tfvars is gitignored to protect your credentials
    $ cp terraform.tfvars{.example,}

    # add your credentials
    $ vi terraform.tfvars
    ```
1. Disable the remote backend in [main.tf](./main.tf) by commenting the block
   out - we first need a bucket before we can store our state in a remote backend
1. Initialise terraform
    ```bash
    $ terraform init
    ```
1. View the plan
    ```bash
    $ terraform plan
    ```
1. Create the space
    ```bash
    $ terraform apply -auto-approve
    ```
1. Add your credentials and space details to a backend config file:
    ```shell
    # *.gitignore.tfvars files are gitignored to protect your credentials
    $ cp backend.gitignore.tfvars{.example,}

    # add your credentials
    $ vi backend.gitignore.tfvars
    ```
1. Enable the backend in [main.tf](./main.tf) by uncommenting it
1. Initialise terraform with the new backend details
    ```bash
    $ terraform init -backend-config=backend.gitignore.tfvars
    # or, if required
    $ terraform init -backend-config=backend.gitignore.tfvars -migrate-state
    ```
1. Visit your bucket to see the uploaded `terraform.tfstate`
1. Clean up

    ```bash
    $ terraform destroy -auto-approve
    ```

## Importing an existing space into Terraform state

Using the configs in this example:

1. Initialise terraform:

    ```shell
    $ terraform init
    ```
1. Import the space
    ```shell
    $ terraform import digitalocean_spaces_bucket [region],[name-of-bucket]
    ```
