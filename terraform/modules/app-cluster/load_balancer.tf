resource "aws_alb" "main" {
  name = "hello-world-api-lb"
  subnets = [
    data.aws_cloudformation_stack.landing_zone.outputs["DMZSubnetA"],
    data.aws_cloudformation_stack.landing_zone.outputs["DMZSubnetB"],
    data.aws_cloudformation_stack.landing_zone.outputs["DMZSubnetC"],
  ]
  security_groups = [
    aws_security_group.lb.id,
  ]

  //tags = local.default_tags
}

resource "aws_alb_target_group" "app" {
  name        = "hello-world-target-group"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  //tags = local.default_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = var.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}
