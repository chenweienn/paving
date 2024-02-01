# Web Load Balancer

resource "aws_lb" "web" {
  name                             = "${var.environment_name}-web-lb"
  load_balancer_type               = "application"
  internal                         = false
  enable_cross_zone_load_balancing = true
  subnets                          = aws_subnet.infra-subnet[*].id
  security_groups                  = [aws_security_group.web_lb_sg.id]
}

resource "aws_lb_listener" "web-80" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-80.arn
  }
}

data "aws_secretsmanager_secret" "cert-secret" {
  provider = aws.plat-auto
  arn      = var.https_listener_cert_secret_arn
}

data "aws_secretsmanager_secret_version" "cert-secret-version" {
  provider  = aws.plat-auto
  secret_id = data.aws_secretsmanager_secret.cert-secret.id
}

resource "aws_iam_server_certificate" "https-listener-cert" {
  name_prefix       = "${var.environment_name}-web-lb-https-listener-cert"
  private_key       = jsondecode(data.aws_secretsmanager_secret_version.cert-secret-version.secret_string)["private_key"]
  certificate_body  = jsondecode(data.aws_secretsmanager_secret_version.cert-secret-version.secret_string)["certificate_body"]
  certificate_chain = jsondecode(data.aws_secretsmanager_secret_version.cert-secret-version.secret_string)["certificate_chain"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "web-443" {
  load_balancer_arn = aws_lb.web.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "${var.https_listener_ssl_policy}"
  certificate_arn   = aws_iam_server_certificate.https-listener-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-443.arn
  }
}

resource "aws_lb_target_group" "web-80" {
  name     = "${var.environment_name}-web-tg-80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    protocol            = "HTTP"
    port                = 8080
    healthy_threshold   = 6
    unhealthy_threshold = 3
    interval            = 5
    timeout             = 3
    path                = "/health"
  }
}

resource "aws_lb_target_group" "web-443" {
  name     = "${var.environment_name}-web-tg-443"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    protocol            = "HTTP"
    port                = 8080
    healthy_threshold   = 6
    unhealthy_threshold = 3
    interval            = 5
    timeout             = 3
    path                = "/health"
  }
}

# SSH Load Balancer

resource "aws_lb" "ssh" {
  name                             = "${var.environment_name}-ssh-lb"
  load_balancer_type               = "network"
  internal                         = false
  enable_cross_zone_load_balancing = true
  subnets                          = aws_subnet.infra-subnet[*].id
  security_groups                  = [aws_security_group.ssh_lb_sg.id]
}

resource "aws_lb_listener" "ssh" {
  load_balancer_arn = aws_lb.ssh.arn
  port              = 2222
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ssh.arn
  }
}

resource "aws_lb_target_group" "ssh" {
  name     = "${var.environment_name}-ssh-tg"
  port     = 2222
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    protocol = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 6
    interval            = 10
  }
}

# TCP Load Balancer

resource "aws_lb" "tcp" {
  name                             = "${var.environment_name}-tcp-lb"
  load_balancer_type               = "network"
  internal                         = false
  enable_cross_zone_load_balancing = true
  subnets                          = aws_subnet.infra-subnet[*].id
  security_groups                  = [aws_security_group.tcp_lb_sg.id]
}

# parse var.tcp_lb_ports (e.g., "20000-20002") into a set of ports
locals {
  tcp_ports = toset([
    for p in range( split("-","${var.tcp_lb_ports}")[0], split("-","${var.tcp_lb_ports}")[1] + 1 ) : tostring(p)
  ])
}

resource "aws_lb_listener" "tcp" {
  #for_each = toset( range(split("-","${var.tcp_lb_ports}")[0], split("-","${var.tcp_lb_ports}")[1] + 1) )
  for_each = local.tcp_ports


  load_balancer_arn = aws_lb.tcp.arn
  port              = each.key
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp[each.key].arn
  }
}

resource "aws_lb_target_group" "tcp" {
  #count = local.tcp_port_count
  #for_each = toset( range(split("-","${var.tcp_lb_ports}")[0], split("-","${var.tcp_lb_ports}")[1] + 1) )
  # for_each = toset(range(2000,2010))
  for_each = local.tcp_ports
  

  name     = "${var.environment_name}-tcp-tg-${each.key}"
  port     = each.key
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id


  health_check {
    protocol = "TCP"
  }
}
