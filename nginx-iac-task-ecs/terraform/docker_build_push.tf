resource "null_resource" "docker_build_push" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.nginx.repository_url}
      docker build -t nginx-phrase ../
      docker tag nginx-phrase:latest ${aws_ecr_repository.nginx.repository_url}:latest
      docker push ${aws_ecr_repository.nginx.repository_url}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.nginx]
}
