# 1. Subnet Group: Dice a RDS quali subnet può usare (quelle "Data")
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${terraform.workspace}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-db-subnet-group"
  }
}

# Security Group: traffico verso il db (5432) abilitato solo dall'interno della VPC
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-${terraform.workspace}-rds-sg"
  description = "Allow PostgreSQL inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-rds-sg"
  }
}

# Istanza RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier        = "${var.project_name}-${terraform.workspace}-postgres"
  engine            = "postgres"
  engine_version    = "16.3" # Versione stabile recente
  instance_class    = var.instance_class
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Impostazioni per Lab/Dev (NON USARE IN PROD così)
  skip_final_snapshot = true  # Permette di distruggere il DB senza fare snapshot obbligatori
  publicly_accessible = false # Sicurezza: NO accesso pubblico
  multi_az            = false # Risparmio costi per il lab

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-rds"
  }
}