terraform {
  required_version = "1.7.0"

  backend "s3" {
    bucket         = "terraform-state-storage-977306314792"
    dynamodb_table = "terraform-state-lock-977306314792"
    key            = "hw-static-site-stg/app.tfstate"
    region         = "us-west-2"
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

module "app" {
  source = "../../modules/app/"
  env    = local.env
}

output "s3_bucket" {
  value = module.app.s3_bucket
}

output "cf_distribution_id" {
  value = module.app.cf_distribution_id
}

output "url" {
  value = module.app.url
}
