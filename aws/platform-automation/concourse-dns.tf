
#data "aws_route53_zone" "hosted" {
#  name = var.hosted_zone
#}

resource "aws_route53_record" "concourse" {
  name = "concourse.${var.environment_name}.${aws_route53_zone.hosted.name}"
  zone_id = aws_route53_zone.hosted.zone_id
  #name = "opsmanager.${var.environment_name}.${data.aws_route53_zone.hosted.name}"
  #zone_id = data.aws_route53_zone.hosted.zone_id

  type    = "A"

  alias {
    name                   = aws_lb.concourse.dns_name
    zone_id                = aws_lb.concourse.zone_id
    evaluate_target_health = true
  }
}
