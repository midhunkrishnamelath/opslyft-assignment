resource "aws_api_gateway_vpc_link" "exampleservice_link" {
  name = "vpc-link-exampleservice"
  target_arns = [var.nlb_arn]
}