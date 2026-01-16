terraform {
  backend "s3" {
    bucket         = "terralab-risorse-0x2-tf-state-sviluppo" # bootstrap output
    key            = "terralab/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terralab-risorse-0x2-tf-locks" # bootstrap output
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  nome_progetto = "${var.project_name}-${terraform.workspace}"
  region        = var.aws_region
  vpc_cidr      = "172.20.0.0/16"

  public_subnet_cidrs       = ["172.20.1.0/24", "172.20.2.0/24"]
  private_app_subnet_cidrs  = ["172.20.11.0/24", "172.20.12.0/24"]
  private_data_subnet_cidrs = ["172.20.21.0/24", "172.20.22.0/24"]

  enable_nat_gateway = true

  tags = {
    "Environment" = terraform.workspace
  }
}

module "eks" {
  source = "./modules/eks"

  nome_progetto = "${var.project_name}-${terraform.workspace}"

  # Qui passi l'output del modulo VPC alla variabile del modulo EKS
  subnet_ids = module.vpc.private_app_subnet_ids

  tags = {
    "Environment" = terraform.workspace
  }
}