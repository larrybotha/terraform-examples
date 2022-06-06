module "bucket" {
  source = "./modules/s3-bucket"
  tags   = var.tags
  name   = var.bucket_name
}
