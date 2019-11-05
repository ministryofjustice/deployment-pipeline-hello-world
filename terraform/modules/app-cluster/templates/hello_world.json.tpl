[
  {
    "name": "${service}",
    "image": "${app_image}:${container_version}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "hello-world-ecs",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      },
      {
        "containerPort": ${management_port},
        "hostPort": ${management_port}
      }
    ]
  }
]
