variable "region" {
  default = "eu-west-2"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "helloWorldTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role Name"
  default     = "helloWorldAutoScaleRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "902837325998.dkr.ecr.eu-west-2.amazonaws.com/laa-ccms-deployment-spike:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8080
}

variable "management_port" {
  description = "Port exposed by the docker image for the management interface"
  default     = 8081
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "health_check_path" {
  default = "/actuator/health"
}

// See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "vpc_id" {
  description = "VPC ID - will need to vary per environment/account"
  // development
}

variable "certificate_arn" {
  description = "The certificate for the ALB Listener"
}

locals {
  service = "hello-world"

  default_tags = {
    business-unit = "LAA"
    application   = "Deployment Pipeline Hello World"
    // TODO: this should vary per environment
    environment-name       = "${terraform.workspace}"
    owner                  = "laa-role-sre@digital.justice.gov.uk"
    infrastructure-support = "LAA WebOps: laa-role-sre@digital.justice.gov.uk"
    // TODO: this should vary per environment
    is-production = "false"
  }
}
