output "vpc_id" {
  description = "L'ID della VPC creata dal modulo."
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Gli ID delle subnet pubbliche."
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnets" {
  description = "Gli ID delle subnet private per le app."
  value       = module.vpc.public_subnet_ids
}

output "private_data_subnet" {
  description = "Gli ID delle subnet private per i dati."
  value       = module.vpc.private_data_subnet_ids 
}