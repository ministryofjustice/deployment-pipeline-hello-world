terraform {
  backend "s3" {
    bucket               = "laa-digital-terraform-state"
    region               = "eu-west-2"
    key                  = "ccmsdeploymentspike.tfstate"
    workspace_key_prefix = "laa-platform"
    role_arn             = "arn:aws:iam::902837325998:role/CircleCi"
  }
}

provider "aws" {
  region = var.region

  assume_role {
    role_arn     = var.environment_terraform_role
  }
}

provider "aws" {
  region = var.region
  alias  = "shared-services"

  assume_role {
    role_arn     = "arn:aws:iam::902837325998:role/TerraformRole"
  }
}

// This should go in the laa-aws-infrastructure repository
//resource "aws_ecr_repository" "ccms_deployment_spike" {
//  name = "laa-ccms-deployment-spike"
//  provider = aws.shared-services
//}

module "cluster" {
  source = "./modules/app-cluster"
  region = var.region
  providers = { # Assumes the role in the development account
    aws = "aws"
  }
  vpc_id = var.vpc_id
}
