output nlb_arn {
  value       = aws_lb.exampleservice_nlb.arn
  description = "ARN for the internal NLB"
}

output nlb_dns_name {
  value       = aws_lb.exampleservice_nlb.dns_name
  description = "DNS name for the internal NLB"
}