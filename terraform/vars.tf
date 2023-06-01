variable "environment" {
  description = "The environment being deployed (default: dev)"
  default     = "dev"
}

variable "vpc_name" {
  description = "The name of the the vpc for the environemt "
  default     = "terraform-test"
}

variable "aws_region" {
  description = "The name of the the vpc for the environemt "
  default     = "us-east-1"
}

 variable "cidr_vpc" {
  description = "The cidr block of the the vpc for the environemt "
  default     = "10.0.0.0/16"
}

variable "cidr_private-subnet-1" {
  description = "The cidr block of the the vpc subnet for the environemt "
  default     = "10.0.1.0/24"
}

variable "cidr_private-subnet-2" {
  description = "The cidr block of the the vpc subnet for the environemt"
  default     = "10.0.2.0/24"
}

