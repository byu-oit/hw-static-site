variable "env" {
  type = string
}

locals {
  subdomain = (var.env == "prd") ? "hw-static-site" : "hw-static-site-${var.env}" # This is the human friendly URL for your website.
  url       = "${local.subdomain}.byu.edu"
}

resource "aws_route53_zone" "zone" {
  name = local.url
}

output "hosted_zone" {
  value = aws_route53_zone.zone
}
