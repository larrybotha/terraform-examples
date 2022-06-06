terraform {
  required_version = "~> 1.2.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

module "cdn" {
  source = "./modules/cdn"
  tags   = { environment : "dev" }
  name   = var.bucket_name
}

locals {
  bucket_objects = toset([
    for x in ["/assets/index.html"] : "${path.module}/${x}"
  ])
}

resource "aws_s3_bucket_object" "objects" {
  bucket   = module.bucket.id
  for_each = local.bucket_objects

  key    = each.value
  source = each.value
  etag   = filemd5(each.value)
}
