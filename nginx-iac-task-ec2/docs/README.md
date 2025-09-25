NGINX Deployment with Terraform

📌 Overview

This project provisions three NGINX instances on AWS using Terraform.
Key requirements met:

All instances sit behind an Application Load Balancer (ALB).

NGINX runs in a Docker container on each instance.

No direct public access to the VMs – only via ALB.

Service remains available if up to two instances fail (high availability).

HTTPS supported via ALB listener.

/phrase endpoint returns 200 OK.

Infrastructure is repeatable and can be recreated from scratch.

## Repository Structure
terraform/ # All Terraform configuration files
├── provider.tf # AWS provider configuration
├── vpc.tf # VPC, subnets, NAT gateway
├── alb.tf # Application Load Balancer + target group + listener
├── asg.tf # Launch template + Auto Scaling Group
├── security_groups.tf # ALB + EC2 security groups
├── variables.tf # Input variables
├── outputs.tf # Outputs (ALB DNS, test commands, etc.)
├── nginx.sh # User-data script to install Docker + run NGINX container


🏗️ Architecture

VPC with public & private subnets

EC2 Auto Scaling Group (min: 3, max: 3) running Docker + NGINX

Application Load Balancer (ALB) for HTTPS termination

Target Group forwarding traffic to NGINX containers

Security Groups

ALB: allows inbound HTTPS (443) from the internet

EC2: allows inbound only from ALB

IAM Role for EC2 to run Docker


🚀 Deployment Instructions
1. Prerequisites

AWS CLI configured (aws configure)

Terraform >=1.2.5 installed

Docker installed (for local testing, optional)

2. Clone the Repository
git clone <your-repo-url>
cd <repo-folder>

3. Initialize Terraform
terraform init

4. Validate & Plan
terraform validate
terraform plan

5. Apply the Infrastructure
terraform apply -auto-approve

6. Test the Endpoint

Once deployed, Terraform will output the ALB DNS name. Test with:

curl -k https://<alb-dns>/phrase

Expected output:

200 OK

High Availability Test (service must continue if 2 instances go down):

# Stop 2 instances (replace with actual IDs from Terraform output)
aws ec2 stop-instances --instance-ids i-1234567890abcdef i-abcdef1234567890

# Test again
curl -i http://<alb-dns>/phrase

# Start them back
aws ec2 start-instances --instance-ids i-1234567890abcdef i-abcdef1234567890

Now test again , you should still get 200 OK.



🔧 Future Improvements 

HTTPS / ACM (Optional, for future)
Currently, HTTPS is not configured, since no domain is available.When a domain is available:
Create an ACM certificate in the desired region.
Add acm_certificate_arn variable in Terraform.
Add HTTPS listener in alb.tf:


Add CloudWatch alarms, ALB access logging, and centralized logging for containers.

Add Ansible for container provisioning (to fully automate user-data/docker setup).

Use Terraform modules for reusability.

Add Route 53 DNS + ACM certificate instead of self-signed TLS.

Configure autoscaling policies for real-world workloads.

Store Terraform state in S3 with DynamoDB locking. 


AI usage: I used ChatGPT to help write documentation. All code, infrastructure changes and testing were done and verified manually by me.

