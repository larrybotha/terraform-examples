# Digitalocean droplet created using Terraform, provisioned using Ansible

This repo demonstrates how to create droplets on Digitalocean using Terraform
and Cloud Init, with Digitalocean's recommended user configs, and subsequently
provisioning the droplet using Ansible.

## Why

Provisioning a droplet requires the following non-trivial steps:

- creating a secure droplet with a non-root user
  - create an SSH
  - create a droplet
  - use cloud-init to create the non-root user
  - generate a hosts file for Ansible
- provision the droplet with Ansible
  - use the non-root user to run the playbook against the generated hosts file

This repo serves is a runnable example for the entire process.

## Instructions

1. Install Terraform and Ansible on your machine
2. Configure Digitalocean personal access token:
   1. Create a token in Digitalocean
   2. Make it available to Terraform on your local machine:
      ```bash
      $ export DO_ACCESS_TOKEN=your-access-token
      ```
3. Configure a local SSH key
   1. Create a key without a passphrase
      ```bash
      $ ssh-keygen -t rsa -f ./my-key
      ```
   2. Update the name of your public key if it's not `my-key` in
      [`variables.tf`](./variables.tf):
      ```hcl
      variable "ssh_key" {
          # ...
          default = {
              # ...
              public_key_file = "../[your-key].pub"
          }
      }
      ```
4. Initialise Terraform:
   ```bash
   $ terraform -chdir=./terraform init
   ```
5. View the plan
   ```bash
   $ terraform -chdir=./terraform plan \
        -var=do_access_token=$DO_ACCESS_TOKEN
   ```
6. Execute the plan
   ```bash
   $ terraform -chdir=./terraform apply \
        -var=do_access_token=$DO_ACCESS_TOKEN -auto-approve
   ```
7. SSH into a droplet
   ```bash
   $ ssh app@$(terraform -chdir=./terraform output -json ip_address | jq -r '.[0]') -i ./terraform/my-key
   $ exit
   ```
8. Clean up
   ```bash
   $ terraform -chdir=./terraform destroy \
       -var=do_access_token=$DO_ACCESS_TOKEN -auto-approve
   ```

## Notes

- use `$ ansible docean_droplets -m ping -o` to ping the server instances in the
  `docean_droplets` hosts group

## Links

- [Hashicorp - Digitalocean Provider][hashi-docean-provider]
- [Digitalocean - How to manage remote servers with Ansible][docean-how-to-terraform]

<!-- Links -->

[hashi-docean-provider]: https://learn.hashicorp.com/tutorials/terraform/digitalocean-provider?in=terraform/applications "Terraform - Digitalocean Provider"
[docean-manage-remote-servers-ansible]: https://www.digitalocean.com/community/tutorial_series/how-to-manage-remote-servers-with-ansible "Digitalocean - How to use Terraform with Digitalocean"
