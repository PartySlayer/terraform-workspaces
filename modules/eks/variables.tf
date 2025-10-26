variable "nome_progetto" {
  description = "Il nome del progetto, usato come prefisso per tutte le risorse."
  type        = string
}

variable "region" {
  description = "La regione AWS in cui creare le risorse."
  type        = string
  default     = "eu-west-1"
}

variable "tags" {
  description = "Una mappa di tag da applicati a tutte le risorse."
  type        = map(string)
  default = {
    "Terraform"      = "true"
    "SourceModule"   = "EKS-Module"
  }
}