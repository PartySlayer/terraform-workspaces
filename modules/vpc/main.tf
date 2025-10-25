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

  # Lista di subnets per for_each da mappa di subnets_cidrs
  # Il nome univoco ("public_0" [..]) sarà la key

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

# Risorsa che crea tutte le subnet
# Una mappa dalla lista 'local.subnets' con il nome della subnet come chiave e i dati come valore

resource "aws_subnet" "this" {

  for_each = { for s in local.subnets : s.key => s }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.type == "public"

  tags = merge(var.tags, {
    Name = "${var.nome_progetto}-subnet-${each.value.type}-${each.value.az}"
    Type = "${each.value.type}"
  })
}

#  LOGICA PER LE ROUTE

# Route Table per subnet PUBBLICHE

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_ig.id
  }

  tags = merge(var.tags, {
    Name = "${var.nome_progetto}-rt-public"
  })
}
