# EC2-Based NGINX Deployment

This folder contains Infrastructure as Code (IaC) for deploying NGINX on AWS using **EC2 + Auto Scaling Group (ASG)**.

---
## How to Run
```bash
cd nginx-iac-task-ec2
ansible-playbook deploy-ec2.yml




## What happens Here

1. **Ansible**:
   - Initializes and applies Terraform. 

2. **Terraform** provisions:
   - VPC, subnets, security groups, auto scaling group (ASG) with EC2 instances, application Load Balancer (ALB).
   - User data installs NGINX and serves a `/phrase` endpoint.
   - Waits for EC2 + ALB to stabilize.
   - Tests the `/phrase` endpoint.
   - Outputs **ready-to-run HA test commands**, including stopping/starting EC2 instances to validate load balancer resilience.

---


