# AWS VPC Peering with Terraform

This project demonstrates how to provision a cross-region VPC peering connection on AWS using Terraform. It creates two VPCs in different AWS regions (us-east-1 and us-west-1), establishes a peering connection between them, and deploys EC2 instances in each VPC to test connectivity.

## Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Usage](#usage)
- [Testing VPC Peering](#testing-vpc-peering)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)

## Architecture

```
┌─────────────────────────────────────┐      ┌─────────────────────────────────────┐
│         Primary VPC (us-east-1)     │      │      Secondary VPC (us-west-1)      │
│         CIDR: 10.0.0.0/16           │      │         CIDR: 10.1.0.0/16           │
│                                     │      │                                     │
│  ┌───────────────────────────────┐  │      │  ┌───────────────────────────────┐  │
│  │  Subnet: 10.0.0.0/24          │  │      │  │  Subnet: 10.1.0.0/24          │  │
│  │                               │  │      │  │                               │  │
│  │  ┌─────────────────────────┐  │  │      │  │  ┌─────────────────────────┐  │  │
│  │  │   EC2 Instance          │  │  │      │  │  │   EC2 Instance          │  │  │
│  │  │   (Ubuntu)              │  │  │      │  │  │   (Ubuntu)              │  │  │
│  │  └─────────────────────────┘  │  │      │  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │      │  └───────────────────────────────┘  │
│              │                      │      │              │                      │
│  ┌───────────▼───────────┐          │      │  ┌───────────▼───────────┐          │
│  │  Internet Gateway     │          │      │  │  Internet Gateway     │          │
│  └───────────────────────┘          │      │  └───────────────────────┘          │
└──────────────┬──────────────────────┘      └──────────────┬──────────────────────┘
               │                                            │
               │         VPC Peering Connection             │
               └────────────────────────────────────────────┘
```

## Features

- Cross-Region VPC Peering: Establishes peering between us-east-1 and us-west-1
- Multi-Region Infrastructure: Deploys resources across two AWS regions
- Automated Network Configuration: Creates VPCs, subnets, internet gateways, and route tables
- Security Groups: Configured to allow SSH and inter-VPC communication
- EC2 Instances: Deploys Ubuntu instances in each VPC for testing
- Remote State Management: Uses S3 backend for Terraform state with encryption
- Reusable Configuration: Uses variables and locals for easy customization

## Project Structure

```
.
├── backend.tf           # S3 backend configuration for remote state
├── data.tf              # Data sources for AMIs and availability zones
├── ec2.tf               # EC2 instances and security groups
├── local.tf             # Local values for common tags and user data
├── output.tf            # Output values for VPC and resource IDs
├── provider.tf          # AWS provider configuration for multiple regions
├── terraform.tfvars     # Variable values (SSH key names)
├── variable.tf          # Variable declarations
├── vpc-peering.tf       # VPC peering connection and routes
├── vpc.tf               # VPC, subnet, IGW, and route table resources
└── README.md            # This file
```

## Prerequisites

1. Terraform (>= 1.0)
   ```bash
   terraform --version
   ```

2. AWS Account with appropriate permissions to create:
   - VPCs, Subnets, Internet Gateways
   - EC2 Instances, Security Groups
   - VPC Peering Connections
   - S3 Buckets (for state management)

3. AWS CLI configured with credentials
   ```bash
   aws configure
   ```

4. SSH Key Pair in both regions (us-east-1 and us-west-1)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd TerraformAws-Day15
```

### 2. Create SSH Key Pairs

**Option A: Create new key pair in us-east-1**
```bash
aws ec2 create-key-pair --key-name vpc-peering-demo --region us-east-1 \
  --query 'KeyMaterial' --output text > vpc-peering-demo.pem
chmod 400 vpc-peering-demo.pem
```

**Option B: Import existing public key to both regions**
```bash
# Extract public key from private key
ssh-keygen -y -f vpc-peering-demo.pem > vpc-peering-demo.pub

# Import to us-east-1
aws ec2 import-key-pair --key-name vpc-peering-demo --region us-east-1 \
  --public-key-material fileb://vpc-peering-demo.pub

# Import to us-west-1
aws ec2 import-key-pair --key-name vpc-peering-demo --region us-west-1 \
  --public-key-material fileb://vpc-peering-demo.pub
```

### 3. Configure Variables

Edit `terraform.tfvars`:
```hcl
primary_key_name   = "vpc-peering-demo"
secondary_key_name = "vpc-peering-demo"
```

### 4. Update Backend Configuration

Edit `backend.tf` with your S3 bucket name:
```hcl
terraform {
  backend "s3" {
    bucket       = "your-terraform-state-bucket"
    region       = "ap-south-1"
    key          = "dev/day15/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
```

## Usage

### Initialize Terraform

```bash
terraform init
```

### Review the Plan

```bash
terraform plan
```

### Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to create the resources.

### View Outputs

```bash
terraform output
```

Expected output:
```
igw_primary_id      = "igw-xxxxxxxxx"
igw_secondary_id    = "igw-xxxxxxxxx"
subnet_primary_id   = "subnet-xxxxxxxxx"
subnet_secondary_id = "subnet-xxxxxxxxx"
vpc_primary_id      = "vpc-xxxxxxxxx"
vpc_secondary_id    = "vpc-xxxxxxxxx"
```

## Testing VPC Peering

### 1. Get Instance IPs

```bash
# Primary instance public IP
aws ec2 describe-instances --region us-east-1 \
  --filters "Name=tag:Name,Values=*primary-instance*" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text

# Secondary instance private IP
aws ec2 describe-instances --region us-west-1 \
  --filters "Name=tag:Name,Values=*secondary-instance*" \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text
```

### 2. SSH into Primary Instance

```bash
ssh -i vpc-peering-demo.pem ubuntu@<PRIMARY_PUBLIC_IP>
```

### 3. Ping Secondary Instance

From the primary instance, ping the secondary instance's private IP:
```bash
ping <SECONDARY_PRIVATE_IP>
```

If the VPC peering is working correctly, you should receive ping responses.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted.


