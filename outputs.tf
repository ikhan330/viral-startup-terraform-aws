output "website_bucket_name" {
  description = "Name of the website bucket"
  value       = aws_s3_bucket.website.bucket
}


# output "Sql_database_Name" {
#   description = "Name of the SQL database"
#   value       = aws_db_instance.postgres.db_name

# }


output "VPC_NAME_VIRAL_PROJECT" {

  description = "Name of my  main VPC"
  value       = aws_default_vpc.main-vpc.tags

}

output "Public_Subnet_Description" {
  description = "My Public Subnet Description"
  value       = aws_subnet.Public-Subnet.cidr_block
}


output "Private_Subnet_A_Description" {
  description = "My Private Subnet A Description"
  value       = aws_subnet.Private-Subnet-A.cidr_block
}


output "Private_Subnet_B_Description" {
  description = "My Private Subnet B Description"
  value       = aws_subnet.Private-Subnet-B.cidr_block
}

output "lambda_function_created" {
  description = "lambda function created"
  value       = aws_lambda_function.my_lambda_1.id
}

# output "api_gateway_url" {
#   description = "Base URL for the API Gateway"
#   value       = "${aws_api_gateway_stage.api_stage.invoke_url}/${aws_api_gateway_resource.api_resource.path_part}"
# }