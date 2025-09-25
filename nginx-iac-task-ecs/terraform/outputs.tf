output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer for ECS NGINX service."
  value       = aws_lb.alb.dns_name
}

output "test_phrase_command" {
  description = "Command to test /phrase endpoint of NGINX service through ALB."
  value       = "curl http://${aws_lb.alb.dns_name}/phrase"
}

output "ecs_cluster_name" {
  description = "ECS cluster name where NGINX service is running."
  value       = aws_ecs_cluster.nginx.name
}

output "ecs_service_name" {
  description = "ECS service name for NGINX tasks."
  value       = aws_ecs_service.nginx.name
}

output "running_task_arns_command" {
  description = "Command to list running ECS tasks for NGINX service."
  value       = "aws ecs list-tasks --cluster ${aws_ecs_cluster.nginx.name} --service-name ${aws_ecs_service.nginx.name} --query 'taskArns' --output text"
}

output "stop_first_task_command" {
  description = "Command to stop the first running ECS task to simulate high availability."
  value       = "aws ecs stop-task --cluster ${aws_ecs_cluster.nginx.name} --task $(aws ecs list-tasks --cluster ${aws_ecs_cluster.nginx.name} --service-name ${aws_ecs_service.nginx.name} --query 'taskArns[0]' --output text)"
}

output "stop_second_task_command" {
  description = "Command to stop the second running ECS task to simulate HA scenario."
  value       = "aws ecs stop-task --cluster ${aws_ecs_cluster.nginx.name} --task $(aws ecs list-tasks --cluster ${aws_ecs_cluster.nginx.name} --service-name ${aws_ecs_service.nginx.name} --query 'taskArns[1]' --output text)"
}

output "test_phrase_after_stop_command" {
  description = "Test /phrase endpoint after stopping two tasks to verify service continuity."
  value       = "curl http://${aws_lb.alb.dns_name}/phrase"
}

