# ECS-Based NGINX Deployment

This folder contains Infrastructure as Code (IaC) for deploying NGINX on AWS using **Amazon ECS (Fargate) + ALB**.

---

## How to Run
```bash
cd nginx-iac-task-ecs
ansible-playbook deploy-ecs.yml


## What Happens Here

1. **Ansible**:
   - Initializes and applies Terraform.
   
2. **Terraform** provisions:
   - VPC, subnets, security groups ,ECS cluster and NGINX service, task definition to run NGINX containers, application load balancer (ALB).
   - Waits for ECS tasks + ALB to stabilize.
   - Tests the `/phrase` endpoint.
   - Outputs **ready-to-run HA test commands**, including stopping ECS tasks to validate ALB failover.

---


