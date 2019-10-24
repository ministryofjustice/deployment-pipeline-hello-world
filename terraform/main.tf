terraform {
  backend "s3" {
    bucket               = "laa-digital-terraform-state"
    region               = "eu-west-2"
    key                  = "ccmsdeploymentspike.tfstate"
    workspace_key_prefix = "laa-platform"
    profile              = "laa-shared-services"
  }
}

provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "ccms_deployment_spike" {
  name = "laa-ccms-deployment-spike"
}
