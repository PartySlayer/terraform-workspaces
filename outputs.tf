output "vpc_id" {
  description = "L'ID della VPC creata dal modulo."
  value       = module.vpc_lab.vpc_id
}

output "public_subnets" {
  description = "Gli ID delle subnet pubbliche."
  value       = module.vpc_lab.public_subnet_ids
}

output "private_app_subnets" {
  description = "Gli ID delle subnet private per le app."
  value       = module.vpc_lab.private_app_subnet_ids
}