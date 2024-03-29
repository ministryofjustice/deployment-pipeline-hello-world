variable "region" {
  default = "eu-west-2"
}

variable "environment_terraform_role" {
  description = "The role to assume when running the terraform"
}

variable "vpc_id" {
  description = "VPC ID - will need to vary per environment/account"
}

variable "certificate_arn" {
  description = "The certificate for the ALB Listener"
}

variable "environment_dns" {
  description = "The root that the user will access the application from"
}

variable "container_version" {
  default = "latest"
}
