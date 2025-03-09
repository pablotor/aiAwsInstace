# Main AWS Config
provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

# AWS Config for DNS configuration
provider "aws" {
  alias = "dns"
  profile = var.aws_profile
  region  = var.aws_region
}
