variable "nlb_arn" {
  type = string
  description = "The ARN of the internal NLB"
}

variable "nlb_dns_name" {
  type = string
  description = "The DNS name of the internal NLB"
}

variable "aws_account_id" {
  type = number
}

variable "aws_region" {
  description = "The name of the the vpc for the environemt "
  default     = "us-east-1"
}