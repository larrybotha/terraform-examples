# Digital Ocean / Terraform example

This repo demonstrates how to create droplets on Digital Ocean using Terraform
and Cloud Init, with Digital Ocean's recommended user configs.

## Why

The examples at [Hashicorp][hashi-docean-provider] and
[Digital Ocean][docean-how-to-terraform] were helpful, but I found were lacking
in a few ways:

- the Hashicorp's SSH example didn't allow for passwordless logins
- the Digital Ocean example uses `remote-exec` which is discouraged by Hashicorp
- neither example demonstrated how to configure Digital Ocean's recommended user
  settings

This example has the following features:

- uses cloud-init (instead of `remote-exec`)
- configures a non-root user with sudo
- adds your SSH public key to Digitalocean
- creates multiple droplets

## Instructions

1. Install Terraform on your machine
1. Configure Digitalocean personal access token:
  1. Create a token in Digital Ocean
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
  3. Add the public key to [`app.yml`](./app.yml)

    ```yml
    # ...
    ssh_authorized_keys:
      - ssh-rsa ...
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
  $ ssh app@[droplet-ip]
  $ exit
  ```
6. Clean up

  ```bash
  $ terraform destroy
  ```

## Debugging

To debug cloud-init, [Multipass](https://multipass.run/) allows for running
linux containers in a cross-platform manner.

```bash
$ multipass launch --name test --config-init user_data.yml
```

## Links

- [Hashicorp - Digital Ocean Provider][hashi-docean-provider]
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
