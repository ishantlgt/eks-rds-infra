resource "aws_eip" "nat_eip" {
  #vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_az1.id # attach to a public subnet
    depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "${var.project_name}-${var.environment}-nat"
  }
}

resource "aws_route_table" "nat_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-route-table"
  }
}

resource "aws_route_table_association" "nat_subnet_association" {
  subnet_id      = aws_subnet.private_app_subnet_az1.id
  route_table_id = aws_route_table.nat_route_table.id
}

# Associate second private subnet
resource "aws_route_table_association" "nat_subnet_az2_association" {
  subnet_id      = aws_subnet.private_app_subnet_az2.id
  route_table_id = aws_route_table.nat_route_table.id
}