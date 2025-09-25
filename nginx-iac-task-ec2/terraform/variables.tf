# variables.tf

# Optional ACM certificate ARN for HTTPS (can leave empty if not using HTTPS)
#variable "acm_certificate_arn" {
 # description = "ACM Certificate ARN for HTTPS (optional)"
 # type        = string
 # default     = ""
#}

# AWS region
#variable "aws_region" {
#  description = "AWS region to deploy resources"
#  type        = string
#  default     = "eu-west-1"
#}

# Number of NGINX instances
variable "instance_count" {
  description = "Number of NGINX instances to launch"
  type        = number
  default     = 3
}

