output "region" {
  value   = var.region
  
}

output "project_name" {
  value   = var.project_name
  
}
output "vpc_id" {
  value   = aws_vpc.vpc.id
  
}
output "public_subnet_az1_id" {
  value   = aws_subnet.public_subnet_az1.id
  
}
output "public_subnet_az2_id" {
  value   = aws_subnet.public_subnet_az2.id
  
}

output "private_app_subnet_az1_id" {
  value   = aws_subnet.private_app_subnet_az1.id
  
}
output "private_app_subnet_az2_id" {
  value   = aws_subnet.private_app_subnet_az2.id
  
}
output "internet_gateway" {
  value   = aws_internet_gateway.internet_gateway.id
  
}

output "private_app_subnet_ids" {
  value = [
    aws_subnet.private_app_subnet_az1.id,
    aws_subnet.private_app_subnet_az2.id
  ]
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnet_az1.id,
    aws_subnet.public_subnet_az2.id
  ]
}

#output "private_route_table_id" {
#  value = aws_route_table.private_route_table.id
#}