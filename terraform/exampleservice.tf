#provision an ecr repostiorys 
resource "aws_ecr_repository" "exampleservice_repo" {
  name = "exampleservice_repo"                 
}

#provision ecs task definitions 
resource "aws_ecs_task_definition" "exampleservice_task" {
  family                   = "exampleservice_task"    # task
  container_definitions    = <<TASK_DEFINITION
  [
    {
      "name": "exampleservice_task",
      "image": "${aws_ecr_repository.exampleservice_repo.repository_url}",
      "essential": true,
      "environmentFiles": [
            ],
      "portMappings": [
        {
          "containerPort": 3002,
          "hostPort": 3002
        }
      ],
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "ecs/exampleservice",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
      }
    }
  ]
  TASK_DEFINITION
  requires_compatibilities = ["FARGATE"]       # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"          # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 1024              # Specifying the memory our container requires
  cpu                      = 512               # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
  task_role_arn            = "${aws_iam_role.ecs_task_role.arn}"
}

#provision ecs services
resource "aws_ecs_service" "exampleservice" {
  name            = "exampleservice"                                  # Naming our service
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.exampleservice_task.arn}"      # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1                                               # Setting the number of containers we want deployed to 2
  network_configuration {
    subnets          = ["${aws_subnet.private-subnet-1.id}", "${aws_subnet.private-subnet-2.id}"]
    assign_public_ip = false                                         # Providing our containers with public IP 
    security_groups  = ["${aws_security_group.exampleservice-sg.id}"]     # Setting the security group
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.exampleservice_target_group.arn
    container_name   = "exampleservice_task"
    container_port   = 3002
  }

  depends_on = [
    aws_ecs_task_definition.exampleservice_task,
  ]
}

#security groups for ecs service  
resource "aws_security_group" "exampleservice-sg" {
  name        = "exampleservice-sg"
  description = "Allow inbound traffic for app for port 3002"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "allow inbound traffic from "
    from_port = 3002
    to_port   = 3002
    protocol  = "tcp"
    # Only allowing traffic in from the load balancer security group
    cidr_blocks = [var.cidr_vpc]

  }

  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    cidr_blocks = [var.cidr_vpc]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [
      aws_vpc_endpoint.s3_endpoint.prefix_list_id
    ]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = [var.cidr_vpc]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "exampleservice-sg"
  }
}

# Create NLB for ECS service
resource "aws_lb" "exampleservice_nlb" {
  name               = "exampleservice-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]

  tags = {
    Name = "exampleservice-nlb"
  }
}

# Create Target Group for NLB
resource "aws_lb_target_group" "exampleservice_target_group" {
  name     = "exampleservice-target-group"
  port     = 3002
  protocol = "TCP"
  vpc_id   = aws_vpc.main-vpc.id
  target_type = "ip"

  depends_on  = [
    aws_lb.exampleservice_nlb
  ]
}

# Redirect all traffic from the NLB to the target group
resource "aws_lb_listener" "exampleservice_nlb_listener" {
  load_balancer_arn = aws_lb.exampleservice_nlb.id
  port              = 3002
  protocol    = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.exampleservice_target_group.id
    type             = "forward"
  }
}

resource "aws_cloudwatch_log_group" "exampleservice-log-group" {
  name = "ecs/exampleservice"

  tags = {
    Environment = "${var.environment}"
  }
}