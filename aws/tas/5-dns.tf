data "aws_route53_zone" "hosted" {
  name         = var.hosted_zone
  private_zone = true
}

# associate vpc to hosted_zone
resource "aws_route53_zone_association" "vpc_to_hosted_zone" {
  zone_id = data.aws_route53_zone.hosted.zone_id
  vpc_id  = aws_vpc.vpc.id
}

# A record of Ops Manager
resource "aws_route53_record" "ops-manager" {
  name = "opsmanager.${var.environment_name}.${data.aws_route53_zone.hosted.name}"
  zone_id = data.aws_route53_zone.hosted.zone_id

  type    = "A"
  ttl     = 300

  records = [aws_eip.ops-manager.public_ip]
}

resource "aws_eip" "ops-manager" {
  domain = "vpc"
}


# DNS records for TAS

resource "aws_route53_record" "wildcard-sys" {
  name = "*.sys.${var.environment_name}.${data.aws_route53_zone.hosted.name}"
  zone_id = data.aws_route53_zone.hosted.zone_id
  type    = "A"

  alias {
    name                   = aws_lb.web.dns_name
    zone_id                = aws_lb.web.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "wildcard-apps" {
  name = "*.apps.${var.environment_name}.${data.aws_route53_zone.hosted.name}"
  zone_id = data.aws_route53_zone.hosted.zone_id
  type    = "A"

  alias {
    name                   = aws_lb.web.dns_name
    zone_id                = aws_lb.web.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ssh" {
  name = "ssh.sys.${var.environment_name}.${data.aws_route53_zone.hosted.name}"
  zone_id = data.aws_route53_zone.hosted.zone_id
  type    = "A"

  alias {
    name                   = aws_lb.ssh.dns_name
    zone_id                = aws_lb.ssh.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "tcp" {
  name = "tcp.sys.${var.environment_name}.${data.aws_route53_zone.hosted.name}"
  zone_id = data.aws_route53_zone.hosted.zone_id
  type    = "A"

  alias {
    name                   = aws_lb.tcp.dns_name
    zone_id                = aws_lb.tcp.zone_id
    evaluate_target_health = true
  }
}
