# Data source per ottenere le AZ disponibili nella regione specificata

data "aws_availability_zones" "available" {
  state = "available"
}

# Risorsa per creare la VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.nome_progetto}-vpc"
  })
}

# Risorsa per creare l'Internet Gateway

resource "aws_internet_gateway" "main_ig" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.nome_progetto}-igw"
  })
}

# LOGICA PER LE SUBNET 


# Mappa per associare il tipo di subnet alla lista di CIDR

locals {
  subnet_cidrs = {
    public  = var.public_subnet_cidrs
    private = var.private_app_subnet_cidrs
    data    = var.private_data_subnet_cidrs
  }

  # Lista piatta da mappa subnets_cidrs
  # Il nome univoco ("public_0" [..]) sarà la primary key

  subnets = flatten([
    for type, cidrs in local.subnet_cidrs : [
      for i, cidr in cidrs : {
        key          = "${type}_${i}"
        type         = type
        cidr         = cidr
        az           = data.aws_availability_zones.available.names[i]
      }
    ]
  ])
}

