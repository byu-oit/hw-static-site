variable "env" {
  type = string
}

locals {
  name    = "hw-static-site"
  gh_org  = "byu-oit"
  gh_repo = "hw-static-site"
  # These three lines form the URL for your website.
  # In real life, you should probably use a more human-friendly URL.
  # Something like, "mysite.byu.edu" for prd and "mysite-dev.byu.edu" for dev.
  subdomain = (var.env == "prd") ? "hw-static-site" : "hw-static-site-${var.env}"
  parent    = (var.env == "prd" || var.env == "cpy") ? "byu-oit-terraform-prd.amazon.byu.edu" : "byu-oit-terraform-dev.amazon.byu.edu"
  url       = "${local.subdomain}.${local.parent}"
}

module "acs" {
  source = "github.com/byu-oit/terraform-aws-acs-info?ref=v4.0.0"
}

resource "aws_route53_zone" "zone" {
  name = local.url
}

output "hosted_zone" {
  value = aws_route53_zone.zone
}

module "gha_role" {
  source                         = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                        = "5.24.0"
  create_role                    = true
  role_name                      = "${local.name}-${var.env}-gha"
  provider_url                   = module.acs.github_oidc_provider.url
  role_permissions_boundary_arn  = module.acs.role_permissions_boundary.arn
  role_policy_arns               = module.acs.power_builder_policies[*].arn
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  oidc_subjects_with_wildcards   = ["repo:${local.gh_org}/${local.gh_repo}:*"]
}

