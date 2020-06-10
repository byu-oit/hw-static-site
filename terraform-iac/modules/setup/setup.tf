variable "env" {
  type = string
}

locals {
  # These two lines form the URL for your website.
  # In real life, you should probably use a more human-friendly URL.
  # Something like, "mysite.byu.edu" for prd and "mysite-dev.byu.edu" for dev.
  subdomain = (var.env == "prd") ? "hw-static-site" : "hw-static-site-${var.env}"
  url       = "${local.subdomain}.byu-oit-terraform-dev.amazon.byu.edu"
}

resource "aws_route53_zone" "zone" {
  name = local.url
}

output "hosted_zone" {
  value = aws_route53_zone.zone
}
