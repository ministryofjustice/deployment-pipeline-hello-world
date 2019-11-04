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

// Need this to get Route53 things that we can add our new name to
data "aws_cloudformation_stack" "dns" {
  name = "LAA-dns-${terraform.workspace}"
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
  certificate_arn = var.certificate_arn
  environment_dns = var.environment_dns
}
