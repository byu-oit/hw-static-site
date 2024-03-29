terraform {
  required_version = "1.7.0"

  backend "s3" {
    bucket         = "terraform-state-storage-977306314792"
    dynamodb_table = "terraform-state-lock-977306314792"
    key            = "hw-static-site-stg/setup.tfstate"
    region         = "us-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

locals {
  env = "stg"
}

provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      app              = "hw-static-site"
      env              = local.env
      data-sensitivity = "public"
      repo             = "https://github.com/byu-oit/hw-static-site"
    }
  }
}

module "setup" {
  source = "../../modules/setup/"
  env    = local.env
}

output "hosted_zone_id" {
  value = module.setup.hosted_zone.zone_id
}

output "hosted_zone_name" {
  value = module.setup.hosted_zone.name
}

output "hosted_zone_name_servers" {
  value = module.setup.hosted_zone.name_servers
}

output "note" {
  value = "These NS records need to be manually added to the parent DNS authority (probably QIP or Route 53)."
}
