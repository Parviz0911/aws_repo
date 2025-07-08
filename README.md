# AWS Infrastructure with Terraform

This repository contains Terraform configuration and a GitHub Actions workflow to deploy a simple two-application environment on AWS. It creates:

- A new VPC with two public subnets
- Internet gateway and public route table
- Application Load Balancer with path based routing
- Two target groups (`/path1` -> app1, `/path2` -> app2)
- Launch templates and Auto Scaling groups for each application

## Requirements
- Terraform >= 1.0
- AWS account and credentials

## Deployment
1. Configure your AWS credentials as environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`).
2. Initialize Terraform:
   ```bash
   cd terraform
   terraform init
   ```
3. Review and apply the plan:
   ```bash
   terraform plan
   terraform apply
   ```

The GitHub Actions workflow (`.github/workflows/terraform.yml`) performs the same steps automatically on pushes to the `main` branch.

## Testing Auto Scaling
After deployment, connect to one of the EC2 instances and run:
```bash
sudo amazon-linux-extras install epel -y
sudo yum install stress -y
stress --cpu 2 --timeout 30000
sudo yum install -y htop
```
This will generate CPU load and trigger the Auto Scaling Group to start additional instances if necessary.
