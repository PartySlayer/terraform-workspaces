output "cluster_endpoint" {
  description = "L'endpoint per l'API server di EKS"
  value       = aws_eks_cluster.main_eks.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Il certificato CA per connettersi al cluster"
  value       = aws_eks_cluster.main_eks.certificate_authority[0].data
}

output "cluster_name" {
  description = "Il nome del cluster EKS appena creato"
  value       = aws_eks_cluster.main_eks.name
}