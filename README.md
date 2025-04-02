# Amazon EKS Infrastructure with Terraform

## Overview

This repository provides Terraform configurations for deploying an **Amazon Elastic Kubernetes Service (EKS) cluster** on AWS. The infrastructure follows best practices to ensure scalability, security, and automation using Infrastructure as Code (IaC).

## Architecture

- **Amazon VPC** – A dedicated Virtual Private Cloud with public and private subnets.
- **Amazon EKS Cluster** – A fully managed Kubernetes cluster deployed on AWS.
- **Node Groups** – Auto-scaling groups of EC2 instances for Kubernetes worker nodes.
- **IAM Roles & Policies** – Configured to ensure secure access control.
- **Security Groups** – Properly defined network access rules for controlled communication.
- **Elastic Load Balancer (ELB)** – Handles incoming traffic and distributes across worker nodes.

## Repository Structure

```
📂 modules/
 ├── 📄 vpc.tf  # VPC, subnets, internet gateway, NAT gateway
 ├── 📄 eks.tf  # EKS cluster configuration
 ├── 📄 node_group.tf  # Worker node configurations
 ├── 📄 iam.tf  # IAM roles and policies
 ├── 📄 security.tf  # Security group rules
📂 environments/
 ├── 📂 dev/  # Development environment variables
 ├── 📂 prod/  # Production environment variables
📄 main.tf  # Root module for Terraform execution
📄 variables.tf  # Input variables for configuration
📄 outputs.tf  # Outputs for Terraform resources
📄 README.md  # Documentation
```

## Prerequisites

- Terraform (`>=1.0`)
- AWS CLI configured with necessary permissions
- kubectl installed for interacting with the Kubernetes cluster
- Helm (optional) for managing Kubernetes applications

## Deployment Instructions

### Step 1: Initialize Terraform

```bash
terraform init
```

### Step 2: Validate Configuration

```bash
terraform validate
```

### Step 3: Generate an Execution Plan

```bash
terraform plan -var-file=environments/dev/terraform.tfvars
```

### Step 4: Deploy the Infrastructure

```bash
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Step 5: Configure Kubernetes Access

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
kubectl get nodes
```

### Step 6: Destroy Resources (If Required)

```bash
terraform destroy -var-file=environments/dev/terraform.tfvars
```

## Key Features

✔ **Scalable & Secure Infrastructure** – Built with best practices for production-ready workloads.

✔ **Automated Resource Provisioning** – Ensures consistency in infrastructure deployment.

✔ **Modular & Reusable Configurations** – Supports multiple environments with minimal changes.

✔ **IAM Role-Based Access Control** – Implements secure authentication and authorization policies.
