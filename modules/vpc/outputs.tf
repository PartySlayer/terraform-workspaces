output "vpc_id" {
  description = "L'ID della VPC principale."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "Il CIDR block della VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Lista degli ID delle subnet pubbliche."
  value       = [for s in aws_subnet.this : s.id if s.tags["Type"] == "public"]
}

output "private_app_subnet_ids" {
  description = "Lista degli ID delle subnet private per le applicazioni."
  value       = [for s in aws_subnet.this : s.id if s.tags["Type"] == "private"]
}

output "private_data_subnet_ids" {
  description = "Lista degli ID delle subnet private per i dati."
  value       = [for s in aws_subnet.this : s.id if s.tags["Type"] == "data"]
}

output "internet_gateway_id" {
  description = "L'ID dell'Internet Gateway."
  value       = aws_internet_gateway.this.id
}
