variable "nome_progetto" {
  description = "Il nome del progetto, usato come prefisso per tutte le risorse."
  type        = string
}

variable "region" {
  description = "La regione AWS in cui creare le risorse."
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "Il CIDR block principale per la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Una lista di CIDR per le subnet pubbliche, uno per ogni AZ."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "Una lista di CIDR per le subnet private delle applicazioni."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_data_subnet_cidrs" {
  description = "Una lista di CIDR per le subnet private dei dati."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "enable_nat_gateway" {
  description = "Se 'true', crea un NAT Gateway per permettere alle subnet private di accedere a internet."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Una mappa di tag da applicati a tutte le risorse."
  type        = map(string)
  default = {
    "Terraform"      = "true"
    "SourceModule"   = "VPC-Module"
  }
}