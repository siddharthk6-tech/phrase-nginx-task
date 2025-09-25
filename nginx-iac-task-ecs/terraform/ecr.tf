resource "aws_ecr_repository" "nginx" {
  name = "nginx-phrase"
  force_delete = true
}
