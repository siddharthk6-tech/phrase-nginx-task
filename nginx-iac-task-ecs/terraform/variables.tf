variable "region" {
  default = "eu-west-1"
}

# Optional ACM certificate ARN for HTTPS (can leave empty if not using HTTPS)
#variable "acm_certificate_arn" {
#  description = "ACM certificate ARN for HTTPS"
#  type        = string
#  default     = "arn:aws:acm:REGION:ACCOUNT_ID:certificate/YOUR_CERT_ID" # replace with your ARN
#}