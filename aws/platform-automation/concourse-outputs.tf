locals {
  stable_config_concourse = {
    concourse_lb_security_group_id = aws_security_group.concourse_lb_sg.id
    concourse_lb_security_group_name = aws_security_group.concourse_lb_sg.name
    concourse_lb_target_group_names = [
      aws_lb_target_group.concourse-web.name,
      aws_lb_target_group.concourse-ssh.name,
      aws_lb_target_group.concourse-uaa.name
    ]


    concourse_db_hostname = aws_db_instance.concourse_db.address
    concourse_db_port = aws_db_instance.concourse_db.port
    concourse_db_endpoint = aws_db_instance.concourse_db.endpoint
    concourse_db_username = aws_db_instance.concourse_db.username
    concourse_db_password = random_string.rds_password.result
    concourse_db_ca_cert  = data.curl.rds_ca_cert.response

    concourse_db_security_group_id = aws_security_group.concourse_db_sg.id
    concourse_db_security_group_name = aws_security_group.concourse_db_sg.name

    concourse_dns = aws_route53_record.concourse.name
  }
}

output "stable_config_concourse" {
  value = jsonencode(local.stable_config_concourse)
  sensitive = true
}
