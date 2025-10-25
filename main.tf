provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source        = "./modules/vpc"

  nome_progetto = "terraLAB"
  region        = var.aws_region
  vpc_cidr      = "172.20.0.0/16"

  public_subnet_cidrs      = ["172.20.1.0/24", "172.20.2.0/24"]
  private_app_subnet_cidrs = ["172.20.11.0/24", "172.20.12.0/24"]
  private_data_subnet_cidrs = ["172.20.21.0/24", "172.20.22.0/24"]
  
  enable_nat_gateway = true

  tags = {
    "Environment" = "Sviluppo"
  }
}