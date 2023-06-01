# Define provider and AWS credentials
# terraform {
#     backend "local" {
#     path = "D:/terraform-tfstate/terraform.tfstate"
#   }
#    backend "s3" {
#    bucket = ""
#    key    = "terraform.tfstate"
#    region = "us-east-1"
#  }
# }
provider "aws" {
  region = "us-east-1"  # Update with your desired AWS region
}
