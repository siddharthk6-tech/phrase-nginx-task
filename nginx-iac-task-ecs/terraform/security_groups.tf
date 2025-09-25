# ALB SG - allow HTTP from internet
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg-ecs"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS task SG - allow traffic from ALB on port 80
resource "aws_security_group" "ecs_tasks_sg" {
  name   = "ecs-tasks-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description     = "Allow ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}