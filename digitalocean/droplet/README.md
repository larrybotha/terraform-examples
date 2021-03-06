# Digitalocean / Terraform droplet creation example

This repo demonstrates how to create droplets on Digitalocean using Terraform
and Cloud Init, with Digitalocean's recommended user configs.

## Why

The examples at [Hashicorp][hashi-docean-provider] and
[Digitalocean][docean-how-to-terraform] were helpful, but I found were lacking
in a few ways:

- the Hashicorp's SSH example didn't allow for passwordless logins
- the Digitalocean example uses `remote-exec` which is discouraged by Hashicorp
- neither example demonstrated how to configure Digitalocean's recommended user
  settings

This example has the following features:

- uses cloud-init (instead of `remote-exec`)
- configures a non-root user with sudo
- adds your SSH public key to Digitalocean
- creates multiple droplets

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
2. Initialise Terraform:

    ```bash
    $ terraform init
    ```
3. View the plan

    ```bash
    $ terraform plan
    ```
4. Execute the plan

    ```bash
    $ terraform apply
    ```
5. SSH into a droplet

    ```bash
    $ ssh app@$(terraform output -json ip_address | jq -r '.[0]') -i my-key
    $ exit
    ```
6. Clean up

    ```bash
    $ terraform destroy
    ```

### Store tfstate in Digitalocean space

If you have issues with any of these steps, remove all the generated Terraform
files from the project root.

1. create a space in Digitalocean
2. create an access key and secret
3. uncomment the `backend` lines in [main.tf](./main.tf)
4. add space details to your environment:
    ```bash
    $ export SPACE_ACCESS_KEY=...
    $ export SPACE_SECRET_KEY=...
    $ export SPACE_BUCKET=...
    $ export SPACE_ENDPOINT=...
    $ export SPACE_KEY=...
    $ export SPACE_REGION=...
    ```
5. initialise Terraform with the backend configs:

    ```bash
    terraform init -migrate-state \
        -backend-config "access_key=$SPACE_ACCESS_KEY" \
        -backend-config "secret_key=$SPACE_SECRET_KEY" \
        -backend-config "bucket=$SPACE_BUCKET" \
        -backend-config "endpoint=$SPACE_ENDPOINT" \
        -backend-config "key=$SPACE_KEY" \
        -backend-config "region=$SPACE_REGION"
    ```
6. apply the plan

    ```bash
    $ terraform apply
    ```
7. view the space in Digitalocean for the new file
8. clean up

    ```bash
    $ terraform destroy
    ```

Note: using S3 with DynamoDB is the preferred method for storing, encrypting,
locking, and versioning of `terraform.tfstate` files

## Debugging

To debug cloud-init, [Multipass](https://multipass.run/) allows for running
linux containers in a cross-platform manner.

```bash
$ multipass launch --name test --config-init user_data.yml
```

## Links

- [Hashicorp - Digitalocean Provider][hashi-docean-provider]
- [Digitalocean - How to use Terraform with DigitalOcean][docean-how-to-terraform]
- [Digitalocean - How to use Cloud Config for your initial server setup][docean-cloud-config]

<!-- Links -->
[hashi-docean-provider]:
  https://learn.hashicorp.com/tutorials/terraform/digitalocean-provider?in=terraform/applications
  "Terraform - Digitalocean Provider"
[docean-how-to-terraform]:
  https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean
  "Digitalocean - How to use Terraform with Digitalocean"
[docean-cloud-config]:
  https://www.digitalocean.com/community/tutorials/how-to-use-cloud-config-for-your-initial-server-setup
  "Digitalocean - How to use Cloud Config for your initial server setup"
