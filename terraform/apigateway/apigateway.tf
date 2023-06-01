
# Provision API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "exampleservice-api"
  description = "API Gateway for Example Service"
}

# Create API Gateway authorizer
resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "cognito-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  type                   = "COGNITO_USER_POOLS"
  identity_source        = "method.request.header.Authorization"
  authorizer_uri         = aws_cognito_user_pool.user_pool.arn
  authorizer_credentials = aws_iam_role.api_gateway_role.arn
  provider_arns          = [aws_cognito_user_pool.user_pool.arn]
}

# Create API Gateway resource
resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

# Create API Gateway method
resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# Create API Gateway integration
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "ANY"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:3002/{proxy}"
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.exampleservice_link.id

}


# Create API Gateway deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "stg"
  stage_description = "${md5(file("apigateway.tf"))}" // forces to 'create' a new deployment each run

  # Enable rate limiting
  variables = {
    "rateLimit" = "1000"  # Specify the desired rate limit
     resources = join(", ", [aws_api_gateway_resource.resource.id])
  }
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_api_gateway_integration.integration ]
}
