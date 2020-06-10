terraform {
  backend "s3" {
    bucket         = "terraform-state-storage-977306314792"
    dynamodb_table = "terraform-state-lock-977306314792"
    key            = "hw-static-site-dev/setup.tfstate"
    region         = "us-west-2"
  }
}

provider "aws" {
  version = "~> 2.42"
  region  = "us-west-2"
}

module "setup" {
  source = "../../modules/setup/"
  env    = "dev"
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
  value = <<-EOF
  These name servers records need to be manually added to the parent DNS authority (probably QIP or Route 53)
  Something like:
    ${module.setup.hosted_zone.name} NS [${module.setup.hosted_zone.name_servers}]
  EOF
}
