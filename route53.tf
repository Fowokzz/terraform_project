# get hosted zone details
resource "aws_route53_zone" "project-hosted-zone" {
  name = var.domain_names.domain_name

  tags = {
    Environment = "dev"
  }
}

# awsRoute53Record
resource "aws_route53_record" "project-subdomain" {
  zone_id = aws_route53_zone.project-hosted-zone.zone_id
  name    = var.domain_names.subdomain_name
  type    = "A"

  alias {
    name                   = aws_lb.project-load-balancer.dns_name
    zone_id                = aws_lb.project-load-balancer.zone_id
    evaluate_target_health = true
  }
}

resource "namedotcom_domain_nameservers" "domain_name" {
  domain_name = var.domain_names.domain_name
  nameservers = [
    aws_route53_zone.project-hosted-zone.name_servers[0],
    aws_route53_zone.project-hosted-zone.name_servers[1],
    aws_route53_zone.project-hosted-zone.name_servers[2],
    aws_route53_zone.project-hosted-zone.name_servers[3],
  ]
}
