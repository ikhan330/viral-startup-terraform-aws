variable "project_name" {

  description = "Name of the project"
  type        = string
  default     = "viral-startup"

}


variable "aws_region" {

  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"


}

variable "environment" {

  description = "deployment environment"
  type        = string
  default     = "dev"



}






variable "availability_zone_main" {

  description = "Availability zone for my vpc"
  type        = string
  default     = "ap-south-1a"

}







# RDS database name
variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "viralstartup"
}

# RDS database username
variable "db_username" {
  description = "Username for the PostgreSQL database"
  type        = string
  default     = "dbadmin"
}

# RDS database password
variable "db_password" {
  description = "Password for the PostgreSQL database"
  type        = string
  sensitive   = true
}

# CloudFront website URL for CORS
variable "website_url" {
  description = "CloudFront URL allowed to access the API"
  type        = string
  default     = "https://d10pa4mdz2ylrm.cloudfront.net"
}