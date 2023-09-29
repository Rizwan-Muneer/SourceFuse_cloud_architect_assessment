provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "nginx" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "nginx" {
  vpc_id = aws_vpc.nginx.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.nginx.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.public_subnet_az
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.nginx.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = var.private_subnet_az
}

resource "aws_ecs_cluster" "nginx" {
  name = var.ecs_cluster_name
}

resource "aws_lb" "nginx" {
  name               = var.alb_name
  internal           = var.alb_internal
  load_balancer_type = var.alb_type
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
}

resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-"
  vpc_id      = aws_vpc.nginx.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-"
  vpc_id      = aws_vpc.nginx.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = var.ecs_execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_execution_role_policy" {
  name       = "ecs-execution-role-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  roles      = [aws_iam_role.ecs_execution_role.name]
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = var.ecs_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  cpu    = var.ecs_task_cpu
  memory = var.ecs_task_memory

  container_definitions = <<EOF
[
  {
    "name": "nginx-nginx",
    "image": "nginx:latest",
    "memory": 512,
    "cpu": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "nginx" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.nginx.id
  task_definition = aws_ecs_task_definition.nginx.arn
  launch_type     = "FARGATE"
  desired_count   = var.ecs_desired_count
  network_configuration {
    subnets         = [aws_subnet.private_subnet.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
  depends_on = [aws_lb.nginx]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "Welcome to port 80!"
    }
  }
}

resource "aws_lb_listener_rule" "default_route_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = var.alb_listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }

  condition {
    host_header {
      values = [var.alb_listener_host_header]
    }
  }

  condition {
    path_pattern {
      values = [var.alb_listener_path_pattern]
    }
  }
}

resource "aws_lb_target_group" "nginx" {
  name     = var.alb_target_group_name
  port     = var.alb_target_group_port
  protocol = var.alb_target_group_protocol
  vpc_id   = aws_vpc.nginx.id
}

resource "aws_s3_bucket" "nginx" {
  bucket = var.s3_bucket_name
}

resource "aws_iam_role" "ecs_s3_access_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_write_policy" {
  name        = var.iam_policy_name
  description = var.iam_policy_description

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.nginx.arn,
          "${aws_s3_bucket.nginx.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_write_policy_attachment" {
  policy_arn = aws_iam_policy.s3_write_policy.arn
  role       = aws_iam_role.ecs_s3_access_role.name
}

