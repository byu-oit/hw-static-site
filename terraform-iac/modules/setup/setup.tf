variable "env" {
  type = string
}

locals {
  # These three lines form the URL for your website.
  # In real life, you should probably use a more human-friendly URL.
  # Something like, "mysite.byu.edu" for prd and "mysite-dev.byu.edu" for dev.
  subdomain = (var.env == "prd") ? "hw-static-site" : "hw-static-site-${var.env}"
  parent    = (var.env == "prd" || var.env == "cpy") ? "byu-oit-terraform-prd.amazon.byu.edu" : "byu-oit-terraform-dev.amazon.byu.edu"
  url       = "${local.subdomain}.${local.parent}"
}

resource "aws_route53_zone" "zone" {
  name = local.url
}

output "hosted_zone" {
  value = aws_route53_zone.zone
}
