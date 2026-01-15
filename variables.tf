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