
# Python handler aur dependencies ki ZIP file
# ZIP build_lambda.ps1 se generate hogi
locals {
  lambda_zip_path = "${path.module}/viral-startup-site-bundle/lambda-function/lambda-deployment.zip"
}

# Lambda ke liye IAM role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Lambda ko CloudWatch logs aur VPC networking permissions
resource "aws_iam_role_policy_attachment" "lambda_vpc_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Lambda security group
resource "aws_security_group" "lambda_sg" {
  name        = "${var.project_name}-${var.environment}-lambda-sg"
  description = "Security Group for Backend Lambda inside VPC"
  vpc_id      = aws_default_vpc.main-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-lambda-sg"
  }
}

# Python Lambda function
resource "aws_lambda_function" "my_lambda_1" {
  filename      = local.lambda_zip_path
  function_name = "my_lambda_python_function"
  role          = aws_iam_role.lambda_role.arn

  handler = "handler.lambda_handler"
  runtime = "python3.12"

  # ZIP badalne par Lambda code update hoga
  source_code_hash = filebase64sha256(local.lambda_zip_path)

  # Lambda VPC configuration
  vpc_config {
    subnet_ids = [
      aws_subnet.Private-Subnet-A.id,
      aws_subnet.Private-Subnet-B-1b.id
          ]

    security_group_ids = [
      aws_security_group.lambda_sg.id
    ]
  }

  # Database connection environment variables
  environment {
    variables = {
      ENVIRONMENT = var.environment

      DB_HOST     = aws_db_instance.postgres.address
      DB_NAME     = var.db_name
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
      DB_PORT     = "5432"

      ALLOWED_ORIGIN = var.website_url
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-api"
  }
}
