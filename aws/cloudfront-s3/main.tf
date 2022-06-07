terraform {
  required_version = "~> 1.2.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

locals {
  bucket_objects = toset([
    for x in ["assets/index.html"] : "${path.module}/${x}"
  ])
  cdn_public_key = base64decode(var.cloudfront_public_key)
}


module "cdn" {
  source                = "./modules/cdn"
  tags                  = { environment : "dev" }
  distribution_name     = var.distribution_name
  bucket_name           = var.bucket_name
  bucket_versioning     = var.bucket_versioning
  cloudfront_public_key = local.cdn_public_key
}

resource "aws_s3_bucket_object" "objects" {
  bucket   = module.cdn.bucket_id
  for_each = local.bucket_objects

  key    = each.value
  source = each.value
  etag   = filemd5(each.value)
}
