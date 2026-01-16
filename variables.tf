variable "aws_region" {
  description = "La regione AWS in cui creare le risorse"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Il nome del progetto"
  type        = string
  default     = "terraLAB"
}

variable "db_password_secret" {
  description = "Password per il database RDS"
  type        = string
  sensitive   = true # nasconde il valore nell'output della console
}