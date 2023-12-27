data "aws_route53_zone" "hosted" {
  name         = var.hosted_zone
  private_zone = true
}

resource "aws_route53_record" "ops-manager" {
  name = "opsmanager.${var.environment_name}.${data.aws_route53_zone.hosted.name}"
  zone_id = data.aws_route53_zone.hosted.zone_id

  type    = "A"
  ttl     = 300

  records = [aws_eip.ops-manager.public_ip]
}

resource "aws_route53_zone_association" "vpc_to_hosted_zone" {
  zone_id = data.aws_route53_zone.hosted.zone_id
  vpc_id  = aws_vpc.vpc.id
}
