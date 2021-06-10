variable "env" {
  type = string
}

locals {
  app_name = "hw-static-site"
  # These three lines form the URL for your website.
  # In real life, you should probably use a more human-friendly URL.
  # Something like, "mysite.byu.edu" for prd and "mysite-dev.byu.edu" for dev.
  subdomain = (var.env == "prd") ? local.app_name : "${local.app_name}-${var.env}"
  parent    = (var.env == "prd" || var.env == "cpy") ? "byu-oit-terraform-prd.amazon.byu.edu" : "byu-oit-terraform-dev.amazon.byu.edu"
  url       = "${local.subdomain}.${local.parent}"
}

data "aws_route53_zone" "zone" {
  name = local.url
}

module "s3_site" {
  source         = "github.com/byu-oit/terraform-aws-s3staticsite?ref=v6.0.0"
  site_url       = local.url
  hosted_zone_id = data.aws_route53_zone.zone.id
  s3_bucket_name = "${local.app_name}-${var.env}"
}

output "s3_bucket" {
  value = module.s3_site.site_bucket.bucket
}

output "cf_distribution_id" {
  value = module.s3_site.cf_distribution.id
}

output "url" {
  value = local.url
}
