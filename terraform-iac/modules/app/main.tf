variable "env" {
  type = string
}

locals {
  tags = {
    env              = "${var.env}"
    data-sensitivity = "public"
    repo             = "https://github.com/byu-oit/hw-static-site"
  }
  subdomain = (var.env == "prd") ? "hw-static-site" : "hw-static-site-${var.env}" # This is the human friendly URL for your website.
  url       = "${local.subdomain}.byu.edu"
}

provider "aws" {
  version = "~> 2.42"
  region  = "us-west-2"
}

data "aws_route53_zone" "zone" {
  name = local.url
}

module "s3_site" {
  source         = "github.com/byu-oit/terraform-aws-s3staticsite?ref=v2.0.1"
  site_url       = local.url
  hosted_zone_id = data.aws_route53_zone.zone.id
  s3_bucket_name = local.url
  tags           = local.tags
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
