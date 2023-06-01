# Create Cognito user pool
resource "aws_cognito_user_pool" "user_pool" {
  name = "exampleservice-user-pool"
}

# Create Cognito user pool client
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "exampleservice-user-pool-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

