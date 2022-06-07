# Digitalocean / Terraform droplet creation example

This repo demonstrates how to create a CloudFront distribution proxying an S3
bucket, requiring signed URLs throught a Trusted Key Group in AWS.

This configuration is useful in a number of ways:

- use CloudFront as a CDN
- serve assets over SSL and a FQDN. S3's 'virtual-host-style' URLs currently
  [don't allow for `.`'s in bucket names][aws-virtual-host-style-s3-urls]
- using a subdomain to serve assets in an application
  - e.g. if using a CDN other than CloudFront:
    subdomain.example.com -> CDN -> CloudFront -> S3

## Why

There are a number of moving parts here:

- provisioning a distribution, certificates, bucket, and trusted key groups
- restricting access to the bucket to either signed URLs, or via the
  distribution
- DNS validation of the certificate

This is a lot to tackle all at once in an existing project, so this example is
useful to abstract the core details away from production deployments to evaluate
how the pieces fit together.

This is a working example, inspired by [advancedweb.hu - How to use CloudFront
Trusted Key Groups][advanced-web-article], but also leverages [Terraform
modules][terraform-modules] as an opportunity for me to learn how to use them.

## Instructions

If you have issues with any of these steps, remove all the generated Terraform
files from this folder.

1. create an access key and secret in AWS
2. copy `./terraform.tfvars` from `./terraform.tfvars.example`:
3. add access key, secret key, and bucket name to `./terraform.tfvars`:
4. initialise Terraform with the backend configs:
5. initialise the plan
   ```bash
   $ terraform init
   ```
6. apply the plan
   ```bash
   $ terraform apply
   ```
7. view the provisioned resources in AWS
8. evaluate that signed URLs are working:
   a. prepare environment variables:

   ```shell
   export _PUBLIC_KEY_ID=$(terraform show -json | jq -r .values.outputs.cloudfront_trusted_key_group_name.value)
   export _PRIVATE_KEY=$(cat ./my-key.cloudfront_private.pem)
   export _DOMAIN=$(terraform show -json | jq -r .values.outputs.cloudfront_domain.value)
   ```

   a. generate a signed URL for [`./assets/index.html`](./assets/index.html):

   ```shell
   # 403 when accessed without signed URL
   curl -I https://${_DOMAIN}/assets/index.html

   # 200 with signed URL (after authenticating aws-cli)
   curl $(aws cloudfront sign --url https://${_DOMAIN}/assets/index.html \
      --key-pair-id $_PUBLIC_KEY_ID --private-key $_PRIVATE_KEY \
      --date-less-than $(date -v+1d +%F))

   # =><h1>hello world</h1>
   ```

9. clean up
   ```bash
   $ terraform destroy
   ```

## Links

- [Hashicorp - AWS Provider][hashi-aws-provider]
- [advancedweb.hu article][advanced-web-article]
- [Terraform modules][terraform-modules]
- [Spacelift.io - What are Terraform modules][spacelift-terraform-modules]
- [AWS virtual-host-style S3 bucket URLs][aws-virtual-host-style-s3-urls]

<!-- Links -->

[hashi-aws-provider]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs "Terraform - AWS Provider"
[advanced-web-article]: https://advancedweb.hu/how-to-use-cloudfront-trusted-key-groups-parameter-and-the-trusted-key-group-terraform-resource/ "advancedweb.hub - How to use CloudFront Trusted Key Groups parameter and the trusted_key_group Terraform resource"
[spacelift-terraform-modules]: https://spacelift.io/blog/what-are-terraform-modules-and-how-do-they-work "Spacelift.io - What are Terraform modules"
[terraform-modules]: https://www.terraform.io/language/modules "Terraform - modules"
[aws-virtual-host-style-s3-urls]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/VirtualHosting.html "AWS - Virtual hosting of buckets"
