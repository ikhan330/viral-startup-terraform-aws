




######################## BLOCK VPC #########################


# Change the name of Default VPC

resource "aws_default_vpc" "main-vpc" {
  tags = {
    "Name" = "Viral-Startup-VPC"
  }
}

# Creating Subnet under my main or default vpc

resource "aws_subnet" "Public-Subnet" {
  vpc_id            = aws_default_vpc.main-vpc.id
  cidr_block        = "172.31.1.0/24"
  availability_zone = var.availability_zone_main
  tags = {
    Name = "My-Public-Subnet"
  }

}


######################## SUBNET A BLOCK #########################

# Create Private subnet for my application server

resource "aws_subnet" "Private-Subnet-A" {
  vpc_id            = aws_default_vpc.main-vpc.id
  cidr_block        = "172.31.100.0/24"
  availability_zone = var.availability_zone_main
  tags = {
    Name = "My-Private-Subnet-A"
  }
}




######################## SUBNET B BLOCK #########################

# creating route table for private subnet

resource "aws_route_table" "Private_Route_Table-A" {

  vpc_id = aws_default_vpc.main-vpc.id

  tags = {
    Name = "My-Private-Route-Table-A"
  }

}


# Associating Private subnet to my private route table

resource "aws_route_table_association" "Private_route_table_association_Subnet_A" {
  subnet_id      = aws_subnet.Private-Subnet-A.id
  route_table_id = aws_route_table.Private_Route_Table-A.id # <-- Nayi private table link karein
}





# Create Private subnet for my database 

resource "aws_subnet" "Private-Subnet-B" {
  vpc_id            = aws_default_vpc.main-vpc.id
  cidr_block        = "172.31.200.0/24"
  availability_zone = var.availability_zone_main
  tags = {
    Name = "My-Private-Subnet-B"
  }
}

# creating route table for private subnet

resource "aws_route_table" "Private_Route_Table-B" {

  vpc_id = aws_default_vpc.main-vpc.id

  tags = {
    Name = "My-Private-Route-Table-B"
  }

}


# Associating Private subnet to my private route table

resource "aws_route_table_association" "Private_route_table_association_Subnet_B" {
  subnet_id      = aws_subnet.Private-Subnet-B.id
  route_table_id = aws_route_table.Private_Route_Table-B.id # <-- Nayi private table link karein
}



# Creating Private subnet for database in anoth az


resource "aws_subnet" "Private-Subnet-B-1b" {
  vpc_id            = aws_default_vpc.main-vpc.id
  cidr_block        = "172.31.201.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "My-Private-Subnet-B-1b"
  }
}

# # creating route table for private subnet

resource "aws_route_table" "Private_Route_Table-B-1b" {

  vpc_id = aws_default_vpc.main-vpc.id

  tags = {
    Name = "My-Private-Route-Table-B-1b"
  }

}

# Route table association for database subnet

resource "aws_route_table_association" "Private_route_table_association_Subnet_B-1b" {

  subnet_id      = aws_subnet.Private-Subnet-B-1b.id
  route_table_id = aws_route_table.Private_Route_Table-B-1b.id # <-- Nayi private table link karein

}


######################## DATABASE CREATION TO SUBNET PRIVATE B #########################

#aws subnet group creation rds postre

resource "aws_db_subnet_group" "db_subnets" {
  name       = "my-rds-subnet-group"
  subnet_ids = [aws_subnet.Private-Subnet-A.id, aws_subnet.Private-Subnet-B-1b.id]

}

#Creating POstgress SQL for database
resource "aws_db_instance" "postgres" {
  identifier           = "${var.project_name}-${var.environment}-postgres"
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_subnet_group_name = aws_db_subnet_group.db_subnets.name


  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  skip_final_snapshot = true

  multi_az = true

}




# Allow Lambda to connect to PostgreSQL on RDS
resource "aws_vpc_security_group_ingress_rule" "rds_from_lambda" {
  security_group_id = tolist(
    aws_db_instance.postgres.vpc_security_group_ids
  )[0]

  referenced_security_group_id = aws_security_group.lambda_sg.id

  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432

  description = "Allow PostgreSQL access from Viral Startup Lambda"
}



######################## LAMBDA CREATION#########################

# # # 1. Lambda ka Security Group (Digital Boundary)

# resource "aws_security_group" "lambda_sg" {

#   name = "viralstartup-lambda-sg"
#   description = "Security Group for backend Lambda"
#   vpc_id = aws_default_vpc.main-vpc.id

#   # Outbound Traffic: Lambda ko database aur internet par bahar jaane ki permission



# }





