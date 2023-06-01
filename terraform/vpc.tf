# configure vpc 
resource "aws_vpc" "main-vpc" {
  cidr_block       = "${var.cidr_vpc}"
  enable_dns_support = true
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.vpc_name}"
  }
}

# configure subnet 
resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "${var.cidr_private-subnet-1}"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "${var.cidr_private-subnet-2}"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2"
  }
}

# configure route-table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "private-rt"
  }
}

#attach subnet to route table 
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-rt.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-rt.id
}

# Configure VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id              = aws_vpc.main-vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type   = "Gateway"
  route_table_ids      = ["${aws_route_table.private-rt.id}"]

  tags = {
    Name = "s3-endpoint"
  }
}

# Configure VPC Endpoint for ECR
resource "aws_vpc_endpoint" "ecr_endpoint" {
  vpc_id              = aws_vpc.main-vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = ["${aws_subnet.private-subnet-1.id}", "${aws_subnet.private-subnet-2.id}"]
  security_group_ids = [
    aws_security_group.exampleservice-sg.id,
  ]

  tags = {
    Name = "ecr-docker-endpoint"
  }
}

# Configure VPC Endpoint for ECR API
resource "aws_vpc_endpoint" "ecrapi_endpoint" {
  vpc_id              = aws_vpc.main-vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = ["${aws_subnet.private-subnet-1.id}", "${aws_subnet.private-subnet-2.id}"]
  security_group_ids = [
    aws_security_group.exampleservice-sg.id,
  ]

  tags = {
    Name = "ecr-api-endpoint"
  }
}

# Configure VPC Endpoint for Cloudwatch
resource "aws_vpc_endpoint" "log_endpoint" {
  vpc_id              = aws_vpc.main-vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = ["${aws_subnet.private-subnet-1.id}", "${aws_subnet.private-subnet-2.id}"]
  security_group_ids = [
    aws_security_group.exampleservice-sg.id,
  ]
  tags = {
    Name = "cloudwatch-endpoint"
  }
}

