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

## LOGICA PER LE SUBNET 


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
        key  = "${type}_${i}"
        type = type
        cidr = cidr
        az   = data.aws_availability_zones.available.names[i]
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
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_ig.id
  }

  tags = merge(var.tags, {
    Name = "${var.nome_progetto}-rt-public"
  })
}

# Route table per subnet PRIVATE

resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? length(var.private_app_subnet_cidrs) : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = merge(var.tags, {
    Name = "${var.nome_progetto}-rt-private-${count.index}"
  })
}

# NAT Gateway e EIP (var.enable_nat_gateway true)

resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = [for s in aws_subnet.this : s.id if s.tags["Type"] == "public"][count.index]

  tags = merge(var.tags, {
    Name = "${var.nome_progetto}-nat-gw-${count.index}"
  })

  depends_on = [aws_internet_gateway.main_ig]
}

resource "aws_eip" "nat" {
  count      = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main_ig]

  tags = merge(var.tags, {
    Name = "${var.nome_progetto}-eip-nat-${count.index}"
  })
}

# ASSOCIAZIONI ROUTE TABLES A SUBNETS 

# Associa le subnet pubbliche alla loro route table

resource "aws_route_table_association" "public" {
  for_each = { for k, s in aws_subnet.this : k => s if s.tags["Type"] == "public" }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Associa le subnet private alla loro route table (solo se NAT è abilitato)

resource "aws_route_table_association" "private" {
  for_each = var.enable_nat_gateway ? {
    for k, s in aws_subnet.this : k => s
    if s.tags["Type"] == "private"
  } : tomap({})

  # Selezioniamo le subnet private per app e dati in base al loro tag

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[tonumber(split("_", each.key)[1])].id
}
