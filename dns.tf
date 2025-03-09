# Create the Hosted Zone with domain (only for AWS hosted domains)
# resource "aws_route53_zone" "hosted_zone" {
#   name = var.domain_name
#   provider = aws.dns
# }

# Create DNS record for api redirecting
resource "aws_route53_record" "instance_dns" {
  zone_id = var.hosted_zone_id
  name    = var.dns_record_name
  type    = "A"
  records = [aws_instance.ai_ec2_instance.public_ip]
  ttl     = "60"

  allow_overwrite = true

  provider = aws.dns
}
