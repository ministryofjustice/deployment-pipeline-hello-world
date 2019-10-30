resource "aws_ecs_cluster" "main" {
  name = "hello-world-cluster"
}

data "template_file" "hello_world_app" {
  template = file("${path.module}/templates/hello_world.json.tpl")

  vars = {
    service         = local.service
    app_image       = var.app_image
    app_port        = var.app_port
    fargate_cpu     = var.fargate_cpu
    fargate_memory  = var.fargate_memory
    aws_region      = var.region
    management_port = var.management_port
  }
}

// Need this to get subnet things
data "aws_cloudformation_stack" "landing_zone" {
  name = "LAA-${var.environment}"
}

// Need this to get Route53 things that we can add our new name to
data "aws_cloudformation_stack" "dns" {
  name = "LAA-dns-${var.environment}"
}

# This is the blueprint for our app
resource "aws_ecs_task_definition" "app" {
  family             = "hello-world-task"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE",
  ]
  cpu                   = var.fargate_cpu
  memory                = var.fargate_memory
  container_definitions = data.template_file.hello_world_app.rendered

  //tags = local.default_tags
}

# This ensures we have the required number of containers running
resource "aws_ecs_service" "main" {
  name            = local.service
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [
      aws_security_group.ecs_tasks.id,
    ]
    subnets = [
      data.aws_cloudformation_stack.landing_zone.outputs["AppPrivateSubnetA"],
      data.aws_cloudformation_stack.landing_zone.outputs["AppPrivateSubnetB"],
      data.aws_cloudformation_stack.landing_zone.outputs["AppPrivateSubnetC"],
    ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = local.service
    container_port   = var.app_port
  }

  depends_on = [
    aws_alb_listener.front_end,
    aws_iam_role_policy_attachment.ecs_task_execution_role,
  ]

  //tags = local.default_tags
}
