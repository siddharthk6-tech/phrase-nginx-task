data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "nginx" {
  name_prefix   = "nginx-"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = "t3.micro"
  # user_data     = file("nginx.sh")  # nginx.sh inside terraform folder
  user_data = base64encode(file("${path.module}/nginx.sh"))


  network_interfaces {
    associate_public_ip_address = false  # EC2 in private subnet
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "nginx-instance"
    }
  }
}

resource "aws_autoscaling_group" "nginx" {
  name                      = "nginx-asg"
  max_size                  = 3
  min_size                  = 3
  desired_capacity          = 3
  vpc_zone_identifier       = module.vpc.private_subnets  # Use private subnets
  launch_template {
    id      = aws_launch_template.nginx.id
    version = "$Latest"
  }

  target_group_arns          = [aws_lb_target_group.tg.arn]
  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete               = true

  tag {
    key                 = "Name"
    value               = "nginx-instance"
    propagate_at_launch = true
  }
}

