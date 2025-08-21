output "rds_endpoint" {
  description = "DNS hostname to connect to the RDS instance (without port)"
  value       = aws_db_instance.rds_instance.address
}