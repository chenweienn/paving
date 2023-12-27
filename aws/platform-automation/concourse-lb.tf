# Load Balancer in front of concourse web nodes

resource "aws_lb" "concourse" {
  name                             = "${var.environment_name}-concourse-lb"
  load_balancer_type               = "network"
  internal                         = false
  enable_cross_zone_load_balancing = true
  subnets                          = aws_subnet.infra-subnet[*].id
  security_groups                  = [aws_security_group.concourse_lb_sg.id]
}

resource "aws_lb_listener" "concourse-web" {
  load_balancer_arn = aws_lb.concourse.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.concourse-web.arn
  }
}

resource "aws_lb_listener" "concourse-ssh" {
  load_balancer_arn = aws_lb.concourse.arn
  port              = 2222
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.concourse-ssh.arn
  }
}

resource "aws_lb_listener" "concourse-uaa" {
  load_balancer_arn = aws_lb.concourse.arn
  port              = 8443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.concourse-uaa.arn
  }
}

resource "aws_lb_target_group" "concourse-web" {
  name     = "${var.environment_name}-concourse-web-tg"
  port     = 443
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_target_group" "concourse-ssh" {
  name     = "${var.environment_name}-concourse-ssh-tg"
  port     = 2222
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_target_group" "concourse-uaa" {
  name     = "${var.environment_name}-concourse-uaa-tg"
  port     = 8443
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    protocol = "TCP"
  }
}

