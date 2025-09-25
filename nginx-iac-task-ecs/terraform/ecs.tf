resource "aws_ecs_cluster" "nginx" {
  name = "nginx-cluster"
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn  # <-- Add this

  container_definitions = jsonencode([{
    name      = "nginx"
    image     = "${aws_ecr_repository.nginx.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.nginx.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 3

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http, null_resource.docker_build_push]
}
