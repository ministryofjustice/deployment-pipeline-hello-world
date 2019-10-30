# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "hello-world-api-load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    cidr_blocks = [
      // TODO: ingress should only be from MOJ Cloud Platform and MOJ Internal IP addresses?
      "0.0.0.0/0",
    ]
  }

  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  //tags = local.default_tags
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "hello-world-ecs-tasks-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  // Allow application traffic to hit the Docker containers
  ingress {
    protocol  = "tcp"
    from_port = var.app_port
    to_port   = var.app_port
    security_groups = [
      aws_security_group.lb.id,
    ]
  }

  // Allow the ALB healthchecks to hit the Docker container management interface
  ingress {
    protocol  = "tcp"
    from_port = var.management_port
    to_port   = var.management_port
    security_groups = [
      aws_security_group.lb.id,
    ]
  }

  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  // Allow access from the workspace whilst we don't have an ALB
    ingress {
    protocol  = "tcp"
    from_port = var.app_port
    to_port   = var.app_port
    cidr_blocks = [
      "10.200.0.0/20",
    ]
  }

  //tags = local.default_tags
}
