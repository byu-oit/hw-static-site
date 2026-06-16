variable "env" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "tf_state_bucket" {
  type = string
}

variable "tf_state_lock_table" {
  type = string
}

terraform {
  required_version = ">= 1.8.0"

  backend "s3" {
    bucket         = var.tf_state_bucket
    dynamodb_table = var.tf_state_lock_table
    key            = "hw-static-site-${var.env}/app.tfstate"
    region         = var.aws_region
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

moved {
  from = module.app.module.s3_site
  to   = module.s3_site
}

locals {
  app_name  = "hw-static-site"
  subdomain = var.env == "prd" ? local.app_name : "${local.app_name}-${var.env}"
  parent = (
    var.env == "prd" || var.env == "cpy"
  ) ? "byu-oit-terraform-prd.amazon.byu.edu" : "byu-oit-terraform-dev.amazon.byu.edu"
  url = "${local.subdomain}.${local.parent}"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      app              = local.app_name
      env              = var.env
      data-sensitivity = "public"
      repo             = "https://github.com/byu-oit/hw-static-site"
    }
  }
}

data "aws_route53_zone" "zone" {
  name = local.url
}

module "s3_site" {
  source         = "github.com/byu-oit/terraform-aws-s3staticsite?ref=v7.0.3"
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
