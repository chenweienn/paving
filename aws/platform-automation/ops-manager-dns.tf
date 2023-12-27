# for lab testing, create a private zone associated with vpc
resource "aws_route53_zone" "hosted" {
  name = var.hosted_zone
  vpc {
    vpc_id = aws_vpc.vpc.id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
}


#data "aws_route53_zone" "hosted" {
#  name = var.hosted_zone
#}

resource "aws_route53_record" "ops-manager" {
  name = "opsmanager.${var.environment_name}.${aws_route53_zone.hosted.name}"
  zone_id = aws_route53_zone.hosted.zone_id
  #name = "opsmanager.${var.environment_name}.${data.aws_route53_zone.hosted.name}"
  #zone_id = data.aws_route53_zone.hosted.zone_id

  type    = "A"
  ttl     = 300

  records = [aws_eip.ops-manager.public_ip]
}
