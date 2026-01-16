variable "aws_region" {
  description = "Regione AWS"
  default     = "eu-west-1" # per il progetto terraLAB
}

variable "project_name" {
  description = "Nome del progetto (usato nei prefissi)"
  default     = "terralab-risorse-0x2"
}

variable "environment" {
  description  = "L'ambiente a cui sono riferite le risorse all'interno dello stato remoto"
  default      = "sviluppo"
}
