🚀 Phrase — NGINX IaC (EC2 + ECS)
Overview

This repository contains two ways to satisfy the take-home assignment:

Deploy three NGINX servers behind an ALB.

Each serves /phrase (HTTP 200 OK).

No direct instance access.

Resilience if two instances fail.

Approaches

EC2 approach:

EC2 Auto Scaling Group (3 instances) running Docker-built NGINX via user-data.

Fully reproducible with Terraform.

ECS approach:

ECS Fargate service (3 tasks) with Docker image pushed to ECR automatically (via Terraform null_resource).

Fully reproducible with Terraform.


🚀 Quick Start — One-Line Deploy + Test

EC2 Approach (Terraform + Ansible)
cd nginx-iac-task-ec2
ansible-playbook deploy-ec2.yml

What happens automatically:
Terraform init, plan, apply for EC2 + ALB + ASG.
Waits 7 minutes for instances + ALB to stabilize.
Tests /phrase endpoint (HTTP 200 OK).
Prints ready-made commands to stop two EC2 instances and retest HA.
Manual HA check (optional): just copy the commands from the playbook output.

ECS Approach (Terraform + Ansible)
cd nginx-iac-task-ecs
ansible-playbook deploy-ecs.yml

What happens automatically:
Terraform init, plan, apply for ECS + ALB + ECR.
Builds & pushes Docker image to ECR automatically.
Waits 7 minutes for ECS tasks + ALB to stabilize.
Tests /phrase endpoint (HTTP 200 OK).
Prints ready-made commands to stop first two ECS tasks and retest HA.
Manual HA check (optional): just copy the commands from the playbook output.

Both approaches:

Expose NGINX only via an ALB (Internet → ALB → private targets).
/phrase health check returns HTTP 200 OK.
HA simulation possible by stopping two instances/tasks.

Repository Structure
phrase-nginx-task/
├── nginx-iac-task-ec2/
│   ├── terraform/
│   │   ├── provider.tf
│   │   ├── vpc.tf
│   │   ├── alb.tf
│   │   ├── asg.tf
│   │   ├── security_groups.tf
│   │   ├── outputs.tf       # outputs: alb_dns_name, instance IDs, test commands
│   │   └── nginx.sh          # user-data: installs docker, builds & runs container
│   ├── deploy-ec2.yml        # Ansible playbook: terraform apply + endpoint test + HA commands
│
├── nginx-iac-task-ecs/
│   ├── terraform/
│   │   ├── provider.tf
│   │   ├── vpc.tf
│   │   ├── alb.tf
│   │   ├── ecr.tf
│   │   ├── ecs.tf
│   │   ├── docker_build_push.tf # null_resource: build & push Docker image
│   │   └── outputs.tf          # outputs: alb_dns_name, test & ECS HA commands
│   ├── Dockerfile               # Docker image for NGINX
│   ├── default.conf             # NGINX config with /phrase endpoint
│   ├── index.html               # simple index page
│   ├── deploy-ecs.yml           # Ansible playbook: terraform apply + endpoint test + HA commands
│
├── .gitignore
└── README.md

Prerequisites
AWS account & credentials (aws configure)
Terraform >= 1.2.5
Docker installed (required for ECS build/push via null_resource)


EC2 Approach
Using Terraform only
cd nginx-iac-task-ec2/terraform
terraform init
terraform apply -auto-approve

Get ALB DNS and test:
alb=$(terraform output -raw alb_dns_name)
curl -i http://$alb/phrase   # expect HTTP 200 OK

Using Ansible (automated deploy + test + HA commands)
cd nginx-iac-task-ec2
ansible-playbook deploy-ec2.yml

What it does:
Runs Terraform init, plan, apply
Waits 7 minutes for instances + ALB to stabilize
Tests /phrase endpoint (HTTP 200 OK)
Displays ready-made commands to stop two EC2 instances and retest

Manual HA Testing (if preferred)
# Get instance IDs from ASG
aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?AutoScalingGroupName=='nginx-asg'].Instances[*].InstanceId" --output text

# Stop two instances
aws ec2 stop-instances --instance-ids <id1> <id2>

# Test endpoint (should still return 200 OK)
curl -i http://$alb/phrase

# Start instances back
aws ec2 start-instances --instance-ids <id1> <id2>

ECS Approach
Using Terraform only
cd nginx-iac-task-ecs/terraform
terraform init
terraform apply -auto-approve


Docker image is built & pushed to ECR automatically.
ECS Service runs 3 tasks behind the ALB.

Using Ansible (automated deploy + test + HA commands)
cd nginx-iac-task-ecs
ansible-playbook deploy-ecs.yml


What it does:
Runs Terraform init, plan, apply
Waits 7 minutes for ECS tasks + ALB to stabilize
Tests /phrase endpoint (HTTP 200 OK)
Prints ready-made commands to stop first two ECS tasks and retest

Manual HA Testing (if preferred)
ALB=$(terraform output -raw alb_dns_name)
CLUSTER=$(terraform output -raw ecs_cluster_name)
SERVICE=$(terraform output -raw ecs_service_name)

# Check endpoint
curl -i http://$ALB/phrase

# List tasks
aws ecs list-tasks --cluster $CLUSTER --service-name $SERVICE --query 'taskArns' --output text

# Stop first task
aws ecs stop-task --cluster $CLUSTER --task $(aws ecs list-tasks --cluster $CLUSTER --service-name $SERVICE --query 'taskArns[0]' --output text)

# Stop second task
aws ecs stop-task --cluster $CLUSTER --task $(aws ecs list-tasks --cluster $CLUSTER --service-name $SERVICE --query 'taskArns[1]' --output text)

# Test endpoint again (should still return 200 OK)
curl -i http://$ALB/phrase


ECS will automatically replace stopped tasks to maintain desired_count=3.

Implementation Notes

EC2: nginx.sh builds container at instance boot. Instances in private subnets, ALB in public subnets.
ECS: Docker image built & pushed via Terraform null_resource. ECS Task Definition uses pushed image.

/phrase endpoint returns 200 OK in both approaches.
HA testing possible by stopping 2 instances/tasks.

Outputs Returned by Terraform
EC2:

alb_dns_name — ALB DNS
asg_instance_ids — instance IDs
assignment_status — ready commands for testing / HA simulation

ECS:
alb_dns_name — ALB DNS
ecs_cluster_name — cluster name
ecs_service_name — service name
test_phrase_command — curl endpoint command
running_task_arns_command — list task ARNs
stop_first_task_command / stop_second_task_command — HA simulation

Summary

This repository contains two reproducible Terraform + Ansible implementations to deploy NGINX behind an ALB:
EC2 + ASG: 3 instances, user-data builds Docker container.
ECS Fargate: 3 tasks, automated image build & push to ECR.

Both approaches:

Expose /phrase endpoint (HTTP 200 OK).

Support HA testing (service remains available if two instances/tasks stop).

Provide automated or manual commands to verify functionality.
