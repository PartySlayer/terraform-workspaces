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
  value       = module.vpc.private_app_subnet_ids
}

output "private_data_subnet" {
  description = "Gli ID delle subnet private per i dati."
  value       = module.vpc.private_data_subnet_ids 
}

output "eks_cluster_endpoint" {
  description = "L'endpoint per l'API server di EKS"
  value = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}