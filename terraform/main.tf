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
    role_arn     = "arn:aws:iam::411213865113:role/Terraform"
  }
}

provider "aws" {
  region = var.region
  alias  = "shared-services"

  assume_role {
    role_arn     = "arn:aws:iam::902837325998:role/TerraformRole"
  }
}

resource "aws_ecr_repository" "ccms_deployment_spike" {
  name = "laa-ccms-deployment-spike"
  provider = aws.shared-services
}

module "cluster" {
  source = "./modules/app-cluster"
  region = var.region
  providers = { # Assumes the role in the development account
    aws = "aws"
  }
  app_image = "${aws_ecr_repository.ccms_deployment_spike.repository_url}:latest"
}
