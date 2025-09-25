resource "aws_lb" "alb" {
  name               = "nginx-alb-ecs"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_http2 = true
  idle_timeout = 60

  tags = {
    Name = "nginx-alb-ecs"
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "nginx-tg-ecs"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/phrase"
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "nginx-tg-ecs"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
