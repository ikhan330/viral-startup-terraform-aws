
# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name        = "viral-startup-dev-nat-eip"
    Environment = "dev"
  }
}

# NAT Gateway in the existing public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_eip.id

  # Existing public subnet in ap-south-1a
  subnet_id = "subnet-0cc45163d17ee174b"

  tags = {
    Name        = "viral-startup-dev-nat"
    Environment = "dev"
  }

  depends_on = [aws_eip.nat_eip]
}

# Private subnet A: ap-south-1a
resource "aws_route" "private_a_nat" {
  route_table_id = aws_route_table.Private_Route_Table-A.id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Private subnet B: ap-south-1b
resource "aws_route" "private_b_nat" {
  route_table_id = aws_route_table.Private_Route_Table-B-1b.id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
