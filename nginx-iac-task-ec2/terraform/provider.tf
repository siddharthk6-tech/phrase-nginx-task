provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ACM cert ARN for HTTPS. Leave empty for HTTP/self-signed."
}

