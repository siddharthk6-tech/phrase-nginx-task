resource "aws_lb" "alb" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets  # ALB in public subnet

  enable_http2 = true
  idle_timeout = 60

  tags = {
    Name = "nginx-alb"
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/phrase"
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "nginx-tg"
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

##########################################
# OPTIONAL: Enable HTTPS once you have a domain
##########################################

# HTTP Listener - redirect to HTTPS
#resource "aws_lb_listener" "http" {
#  load_balancer_arn = aws_lb.alb.arn
#  port              = 80
#  protocol          = "HTTP"

#  default_action {
#    type = "redirect"

#    redirect {
#      port        = "443"
#      protocol    = "HTTPS"
#      status_code = "HTTP_301"
#    }
#  }
#}

# HTTPS Listener using existing ACM certificate
#resource "aws_lb_listener" "https" {
#  load_balancer_arn = aws_lb.alb.arn
#  port              = 443
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = var.acm_certificate_arn

#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.tg.arn
#  }
#}

