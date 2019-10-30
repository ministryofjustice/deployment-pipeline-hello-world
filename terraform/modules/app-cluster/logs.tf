# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "hello_world_log_group" {
  name              = "hello-world-ecs"
  retention_in_days = 3

  //tags = local.default_tags
}

resource "aws_cloudwatch_log_stream" "hello_world_log_stream" {
  name           = "hello-world-log-stream"
  log_group_name = aws_cloudwatch_log_group.hello_world_log_group.name
}
