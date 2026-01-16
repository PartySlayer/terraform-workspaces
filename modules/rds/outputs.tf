output "db_endpoint" {
  description = "L'endpoint per connettersi al database"
  value       = aws_db_instance.postgres.address
}

output "db_port" {
  description = "La porta del database"
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "Il nome del database"
  value       = aws_db_instance.postgres.db_name
}