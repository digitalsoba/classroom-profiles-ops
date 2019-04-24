module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "LDAP"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "https"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

data "aws_acm_certificate" "matabit" {
  domain      = "matabit.org"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# ALB for prod and dev
resource "aws_alb" "alb" {
  name                             = "ecs-alb"
  load_balancer_type               = "application"
  security_groups                  = ["${module.alb_sg.this_security_group_id}"]
  internal                         = false
  idle_timeout                     = "60"
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  subnets = [
    "${data.terraform_remote_state.vpc.public_subnet_a}",
    "${data.terraform_remote_state.vpc.public_subnet_b}",
  ]

  tags {
    name = "ecs-alb"
  }

  timeouts {
    create = "10m"
    delete = "10m"
    update = "10m"
  }
}

# Redirect HTTP request to HTTPS
resource "aws_alb_listener" "frontend_http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = "${aws_alb_target_group.alb_target_group_prod.id}"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_alb_listener" "frontend_https" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.aws_acm_certificate.matabit.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_target_group_prod.id}"
  }
}

# Production target group
resource "aws_alb_target_group" "alb_target_group_prod" {
  name     = "target-group-ecs-prod"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags {
    name = "target-group-ecs-prod"
  }
}

# Dev target group
resource "aws_alb_target_group" "alb_target_group_dev" {
  name     = "target-group-ecs-dev"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags {
    name = "target-group-ecs-dev"
  }
}

resource "aws_lb_listener_rule" "dev_listener" {
  listener_arn = "${aws_alb_listener.frontend_https.arn}"
  priority     = 10

  action = {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_target_group_dev.id}"
  }

  condition = {
    field  = "host-header"
    values = ["*dev.matabit.org"]
  }
}
