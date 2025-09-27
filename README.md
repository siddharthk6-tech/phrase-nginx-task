# Phrase NGINX Task – IaC Deployment

This repository contains the **Phrase NGINX deployment task**, implemented in two different ways:

1. **EC2-based deployment** → using Auto Scaling Group (ASG) and an Application Load Balancer (ALB).
2. **ECS-based deployment** → using Amazon ECS with Fargate and an ALB.

Both approaches use Ansible playbooks to drive the deployment. 
The playbooks run terraform init, plan, and apply to provision the infrastructure.
Automatically validate the /phrase endpoint once services are up.
Output ready-to-use High Availability (HA) commands that simulate failures by stopping two EC2 instances or ECS tasks, then re-testing the /phrase URL to confirm resilience.
This provides a complete end-to-end deployment and validation flow with minimal manual steps.

---

## How to Run

### EC2 Deployment
Navigate into the EC2 folder:
cd nginx-iac-task-ec2
ansible-playbook deploy-ec2.yml

### ECS Deployment
Navigate into the ECS folder:
Copy code
cd nginx-iac-task-ecs
ansible-playbook deploy-ecs.yml

### Summary

EC2 Approach → Launches EC2 instances inside an ASG, installs NGINX, and attaches them behind an ALB.

ECS Approach → Deploys an ECS cluster and service (running NGINX containers) behind an ALB.

Both playbooks will output ready-to-run HA test commands (e.g., stopping EC2 instances or ECS tasks to verify resilience).
