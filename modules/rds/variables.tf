variable "project_name" {
  description = "Nome del progetto per i tag"
  type        = string
}

variable "vpc_id" {
  description = "ID della VPC dove creare il Security Group"
  type        = string
}

variable "vpc_cidr" {
  description = "Il CIDR block principale per la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_ids" {
  description = "Lista delle subnet ID dove posizionare il DB (Private Data)"
  type        = list(string)
}

variable "db_username" {
  description = "Username master del DB"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Password master del DB"
  type        = string
  sensitive   = true # Nasconde il valore nei log di terraform plan
}

variable "db_name" {
  description = "Nome del database iniziale"
  type        = string
  default     = "appdb"
}

variable "instance_class" {
  description = "Tipo di istanza RDS"
  type        = string
  default     = "db.t3.micro" # Free tier eligible
}