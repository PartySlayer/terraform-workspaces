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

