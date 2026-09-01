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
    key            = "hw-static-site-${var.env}/setup.tfstate"
    region         = var.aws_region
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.60"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

locals {
  name      = "hw-static-site"
  gh_org    = "byu-oit"
  gh_repo   = "hw-static-site"
  subdomain = var.env == "prd" ? local.name : "${local.name}-${var.env}"
  parent = (
    var.env == "prd" || var.env == "cpy"
  ) ? "byu-oit-terraform-prd.amazon.byu.edu" : "byu-oit-terraform-dev.amazon.byu.edu"
  url = "${local.subdomain}.${local.parent}"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      app              = local.name
      env              = var.env
      data-sensitivity = "public"
      repo             = "https://github.com/byu-oit/hw-static-site"
    }
  }
}

module "acs" {
  source = "github.com/byu-oit/terraform-aws-acs-info?ref=v4.1.0"
}

resource "aws_route53_zone" "zone" {
  name = local.url
}

module "gha_role" {
  source                         = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                        = "6.8.1"
  create_role                    = true
  role_name                      = "${local.name}-${var.env}-gha"
  provider_url                   = module.acs.github_oidc_provider.url
  role_permissions_boundary_arn  = module.acs.role_permissions_boundary.arn
  role_policy_arns               = module.acs.power_builder_policies[*].arn
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  oidc_subjects_with_wildcards   = ["repo:${local.gh_org}/${local.gh_repo}:*"]
}

output "hosted_zone_id" {
  value = aws_route53_zone.zone.zone_id
}

output "hosted_zone_name" {
  value = aws_route53_zone.zone.name
}

output "hosted_zone_name_servers" {
  value = aws_route53_zone.zone.name_servers
}

output "note" {
  value = "These NS records need to be manually added to the parent DNS authority (probably QIP or Route 53)."
}
