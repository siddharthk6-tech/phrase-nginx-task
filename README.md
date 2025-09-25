🚀 Phrase — NGINX IaC (EC2 + ECS)
Overview

This repository contains two ways to satisfy the take-home assignment: deploy three NGINX servers behind an ALB, each serving /phrase (200 OK), no direct instance access, and resilience if two instances fail.

EC2 approach: EC2 Auto Scaling Group (3 instances) running Docker-built NGINX via user-data.

ECS approach: ECS Fargate service (3 tasks) with Docker image pushed to ECR automatically (via Terraform null_resource).

Both approaches:

Expose NGINX only via an ALB (internet → ALB → private targets).

Use /phrase health check (returns 200).

Are reproducible with Terraform.

Actual repository structure (reflects your workspace)
phrase-nginx-task/                     <- repository root
├── nginx-iac-task-ec2/                <- EC2 approach
│   ├── terraform/
│   │   ├── provider.tf
│   │   ├── vpc.tf
│   │   ├── alb.tf
│   │   ├── asg.tf
│   │   ├── security_groups.tf
│   │   ├── outputs.tf           # outputs: alb_dns_name, test commands
│   │   └── nginx.sh             # user-data: installs docker, builds Dockerfile and runs container
│   └── (optional docs / extras)
│
├── nginx-iac-task-ecs/                 <- ECS approach
│   ├── terraform/
│   │   ├── provider.tf
│   │   ├── vpc.tf
│   │   ├── alb.tf
│   │   ├── ecr.tf
│   │   ├── ecs.tf
│   │   ├── docker_build_push.tf  # null_resource to build & push Docker image
│   │   └── outputs.tf            # outputs: alb_dns_name, test commands, ecs commands
│   ├── Dockerfile                 # Dockerfile used to create the nginx image
│   ├── default.conf               # nginx config with /phrase endpoint
│   └── index.html                 # simple index page
│
├── .gitignore
└── README.md                       <- this file


Notes

For EC2 we use nginx.sh (user-data) which builds the image on startup on each EC2 instance.

For ECS we keep Dockerfile, default.conf, and index.html in the ECS folder (next to the terraform/ folder). Terraform’s null_resource will build & push the image to ECR during terraform apply.

Quick prerequisites

AWS account and credentials configured (aws configure)

Terraform >= 1.2.5

Docker installed (only required locally if you want Terraform to build/push for ECS using the null_resource — Docker must be present where you run terraform apply)

Optional: jq for some CLI helpers

How to run — EC2 approach

cd nginx-iac-task-ec2/terraform

Initialize & apply:

terraform init
terraform apply -auto-approve


After apply completes, get the ALB DNS from Terraform outputs:

terraform output -raw alb_dns_name


Or set a variable:

alb=$(terraform output -raw alb_dns_name)
curl -i http://$alb/phrase


Expect: HTTP/1.1 200 OK and body OK.

To simulate HA (stop 2 instances):

Get instance IDs (example):

aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?AutoScalingGroupName=='nginx-asg'].Instances[*].InstanceId" --output text


Stop two:

aws ec2 stop-instances --instance-ids <id1> <id2>
curl -i http://$alb/phrase  # should still return 200 OK from remaining instance


Start them back:

aws ec2 start-instances --instance-ids <id1> <id2>


EC2 implementation details

nginx.sh (user-data) lives at: nginx-iac-task-ec2/terraform/nginx.sh.

The script installs Docker, creates Dockerfile + index.html on the instance, builds image and runs container bound to port 80.

Instances live in private subnets in the final correct config (ALB in public subnets). If you earlier used public subnets, ensure you switch to private subnets and NAT for instance outbound if needed.

How to run — ECS approach (fully automated build & deploy)

cd nginx-iac-task-ecs/terraform

Ensure Docker is installed on the machine where you run terraform apply (Terraform will build & push the image via null_resource).

Initialize & apply:

terraform init
terraform apply -auto-approve


Terraform outputs will include:

alb_dns_name (ALB host)

Ready-to-copy commands such as curl http://<alb>/phrase

ECS helper commands (list tasks, stop first/second task)

Example quick test (use the output or substitute actual DNS):

alb=$(terraform output -raw alb_dns_name)
curl -i http://$alb/phrase    # should return 200 OK


ECS automatic build & push

Dockerfile, default.conf, index.html are at nginx-iac-task-ecs/ root (not inside terraform/).

Terraform docker_build_push.tf contains a null_resource that runs docker build, tag, docker push to the ECR repo created by Terraform.

The ECS Task Definition uses the pushed ECR image URL.

aws_ecs_service is configured with desired_count = 3 so ECS keeps 3 tasks running.

How to test HA on ECS (copy-paste ready)

After terraform apply, Terraform will print helper outputs (examples below are copy/paste-ready — replace with the actual DNS or use terraform output):

# Replace with terraform output if you prefer:
ALB=nginx-alb-xxxxxxxx.eu-west-1.elb.amazonaws.com

# check endpoint
curl -i http://$ALB/phrase

# list running task ARNs
aws ecs list-tasks --cluster nginx-cluster --service-name nginx-service --query 'taskArns' --output text

# stop the first running task
aws ecs stop-task --cluster nginx-cluster --task $(aws ecs list-tasks --cluster nginx-cluster --service-name nginx-service --query 'taskArns[0]' --output text)

# stop the second running task
aws ecs stop-task --cluster nginx-cluster --task $(aws ecs list-tasks --cluster nginx-cluster --service-name nginx-service --query 'taskArns[1]' --output text)

# re-test endpoint (service should still return 200 OK)
curl -i http://$ALB/phrase


ECS will replace stopped tasks to maintain desired_count=3. During replacement the single remaining healthy task should serve traffic — ALB health checks ensure only healthy tasks receive traffic.

Outputs returned by Terraform (examples)

Use terraform output in each module to get these. Typical outputs provided:

alb_dns_name — ALB DNS for testing.

test_phrase_command — ready curl command to test /phrase.

(ECS) running_task_arns_command, stop_first_task_command, stop_second_task_command — ready CLI commands to simulate failures.

Example:

terraform output -raw test_phrase_command
# prints: curl http://nginx-alb-xxxxx.eu-west-1.elb.amazonaws.com/phrase

Important implementation notes

EC2: user-data builds the container on instance boot, so instances do not need an externally built image.

ECS: Terraform builds and pushes the Docker image to ECR via a null_resource (this requires Docker and AWS CLI locally where you run terraform apply).

HTTPS: not configured by default (no public domain). To enable HTTPS later you can:

Create an ACM certificate and provide acm_certificate_arn as a variable.

Add an HTTPS listener in alb.tf that references the ACM cert.

Optionally use Route53 to issue and validate the certificate automatically.

State management: store Terraform state in S3 + DynamoDB locking for team usage (recommended).


SUMMARY- 
This repository contains two reproducible Terraform implementations to deploy three NGINX instances behind an ALB: nginx-iac-task-ec2/ (EC2 + ASG) and nginx-iac-task-ecs/ (ECS Fargate with automated image build + ECR). Each approach configures /phrase healthcheck (returns 200 OK) and supports the requirement that service remains available even when two instances/tasks are stopped. See instructions above to deploy and test.
