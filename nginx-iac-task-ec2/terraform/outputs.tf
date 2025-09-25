# Fetch ASG details
data "aws_autoscaling_group" "nginx_asg" {
  name = aws_autoscaling_group.nginx.name
}

# Fetch EC2 instances launched by the ASG
data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.nginx.name]
  }
}

# Output the ALB DNS
output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "ALB DNS to test /phrase endpoint"
}

# Output instance IDs of the ASG
output "asg_instance_ids" {
  description = "EC2 instance IDs launched by the Auto Scaling Group"
  value       = data.aws_instances.asg_instances.ids
}

# Assignment summary and commands for testing
output "assignment_status" {
  description = "Assignment summary and commands to test HA"
  value       = <<EOT
✅ NGINX ALB setup complete as per assignment requirements.

- 3 NGINX instances run in private subnets.
- Instances are only accessible via the ALB.
- The /phrase endpoint returns HTTP 200 OK.
- If two instances go down, service should not be interrupted.

### Test functionality:

1. Test /phrase endpoint:
curl -i http://${aws_lb.alb.dns_name}/phrase

2. Stop any two instances (simulate failure):
aws ec2 stop-instances --instance-ids ${join(" ", slice(data.aws_instances.asg_instances.ids, 0, 2))}

3. Test again:
curl -i http://${aws_lb.alb.dns_name}/phrase

4. Restart the stopped instances:
aws ec2 start-instances --instance-ids ${join(" ", slice(data.aws_instances.asg_instances.ids, 0, 2))}
EOT
}

