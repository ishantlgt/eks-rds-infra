# Python Application on EKS with RDS, Secrets Manager, ECR, ACM & Autoscaling

[![Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)](https://python.org/)

This repository contains the complete infrastructure and deployment setup for a **Python application** running on **Amazon EKS** inside a **private VPC**. It provisions a **MySQL RDS database**, manages sensitive values via **AWS Secrets Manager**, uses **ACM (AWS Certificate Manager)** for SSL/TLS certificates, and implements **autoscaling** both at the application (pods) and cluster (nodes) level.

The setup is built using a **modular Terraform structure** with environment separation via `.tfvars` files, and Kubernetes manifests for application deployment.

---

## 🏗️ Architecture Overview

### Infrastructure Components

1. **🌐 VPC & Networking**
   - Private & public subnets across multiple AZs
   - NAT Gateway for outbound internet traffic from private subnets
   - Internet Gateway for public subnet connectivity
   - Route tables and security groups for controlled access

2. **☸️ EKS Cluster**
   - Runs inside private subnets for enhanced security
   - [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) to scale worker nodes automatically
   - [Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) to scale pods dynamically
   - [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) for ingress (ALB)
   - [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) for resource monitoring
   - [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/) to mount secrets from Secrets Manager into pods

3. **🗄️ RDS (MySQL)**
   - Multi-AZ deployment for high availability
   - Accessible only from the EKS cluster via security groups
   - Runs inside private subnets

4. **🔐 Secrets Management**
   - Application credentials and DB passwords stored in AWS Secrets Manager
   - Kubernetes pods consume these secrets using the CSI driver + `SecretProviderClass`
   - Automatic secret rotation capabilities

5. **🔒 Certificates (ACM)**
   - SSL/TLS certificates provisioned in **AWS Certificate Manager (ACM)**
   - Certificates automatically attached to the **ALB Ingress** via annotations
   - Supports HTTPS traffic for secure communication

6. **🐍 Python Application**
   - Containerized and stored in **Amazon ECR**
   - Deployed using Kubernetes manifests
   - Exposed via a Kubernetes Service + ALB ingress
   - Scales automatically with HPA (CPU/Memory thresholds)

### High Level Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐
│   Public Subnet │    │   Public Subnet │
│                 │    │                 │
│  Internet GW    │    │   NAT Gateway   │
└─────────────────┘    └─────────────────┘
         │                       │
┌─────────────────┐    ┌─────────────────┐
│  Private Subnet │    │  Private Subnet │
│                 │    │                 │
│  EKS Workers    │    │  RDS MySQL      │
│  Python Pods    │    │                 │
└─────────────────┘    └─────────────────┘
         │                       │
┌─────────────────────────────────────────┐
│            AWS Services                 │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │   ECR   │  │ Secrets │  │   ACM   │ │
│  │         │  │ Manager │  │         │ │
│  └─────────┘  └─────────┘  └─────────┘ │
└─────────────────────────────────────────┘
```

---

## 📂 Project Structure

```
├── project/                              # Project
│   ├── main.tf                        # Root infrastructure definition
│   ├── terraform.tfvars.example       # Environment-specific(example) variables
│   ├── variables.tf                   # Variable definitions
│   ├── AWSLoadBalancerController.json # Load balancer controller policy
│   └── Dockerfile                     # Python application container
│
├── k8/                                # Kubernetes manifests
│   ├── deployment.yaml               # Python app deployment
│   ├── hpa.yaml                      # Horizontal Pod Autoscaler
│   ├── ingress.yaml                  # Ingress (ALB)
│   ├── namespace.yaml                # Kubernetes namespace
│   ├── secrets-provider-class.yaml   # CSI driver secrets config
│   ├── service-account.yaml          # Service account with IAM role
│   └── service.yaml                  # Kubernetes service
│
└── modules/                          # Terraform reusable modules
    ├── ecr/                         # ECR repository
    │   ├── main.tf
    │   ├── variables.tf
    ├── eks/                         # EKS cluster + addons
    │   ├── main.tf
    │   ├── variables.tf
    │   └── metrics-server.tf
    │   ├── cluster-autoscaler.tf
    │   ├── helm-provider.tf
    │   └── lb-controller.tf
    │   ├── pod-identity.tf
    │   ├── secrets-csi-driver.tf
    │  
    ├── rds/                         # MySQL RDS
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── secrets-manager/             # AWS Secrets Manager
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security-groups/             # Security groups
    │   ├── main.tf
    │   ├── variables.tf
    
    └── vpc/                         # VPC, subnets, NAT, routing
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## ⚙️ Prerequisites

Before you begin, ensure you have the following tools installed and configured:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.5
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes command-line tool
- [AWS CLI](https://aws.amazon.com/cli/) v2 - configured with appropriate IAM permissions
- [Docker](https://docker.com/) - for building and pushing container images
- [Helm](https://helm.sh/) - for installing Kubernetes applications (optional)

### AWS IAM Permissions Required

Your AWS user/role needs permissions for:
- VPC, Subnets, Security Groups, NAT Gateway
- EKS Cluster and Node Groups
- RDS (MySQL)
- ECR Repository
- AWS Secrets Manager
- AWS Certificate Manager (ACM)
- IAM Roles and Policies
- Application Load Balancer (ALB)

---

## 🚀 Deployment Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/ishantlgt/eks-rds-infra.git
cd eks-rds-infra
```

### Step 2: Configure Variables

cp `project/terraform.tfvars.example` to `project/terraform.tfvars`  with your specific configuration:

```hcl

region          = "us-east-1"
project_name    = "project"
vpc_cidr        = "10.0.0.0/16"
environment     = "prod"

# Subnets
public_subnet_az1_cidr      = "10.0.0.0/24"
public_subnet_az2_cidr      = "10.0.1.0/24"
private_app_subnet_az1_cidr = "10.0.2.0/24"
private_app_subnet_az2_cidr = "10.0.3.0/24"

# EKS
eks_cluster_name  = "eks"
eks_version       = "1.31"
node_instance_type   = "t2.small"
node_min_capacity    = 1
node_max_capacity    = 1
node_desired_capacity = 1
enable_irsa          = true
enable_private_api   = true
enable_public_api    = true
secret_name          = "app-vars"

# RDS
engine_version = "8.0.42"
rds_storage    = 20
db_name        = "image_db"
db_username    = "db_user"
db_password    = "CHANGE_ME" # <-- do not commit real password
instance_class = "db.t3.micro"

# ECR Images
images = ["image-test"]

# Domain & ACM
domain_name      = "example.teamtalentelgia.com"
san_names        = "www.example.teamtalentelgia.com"
route53_zone_id  = "ZXXXXXXXXXXXXXX"

# S3 for Rekognition
AWS_BUCKET_NAME       = "example-bucket"
AWS_ACCESS_KEY_ID     = "YOUR_AWS_ACCESS_KEY"
AWS_SECRET_ACCESS_KEY = "YOUR_AWS_SECRET_KEY"
AWS_REGION            = "us-east-1"
UPLOAD_DIR            = "uae"
COLLECTION_ID         = "rekognition-uae"

# Database (App side)
MYSQL_USER          = "db_user"
MYSQL_PASSWORD      = "CHANGE_ME"
MYSQL_DB            = "image_db"
DB_HOST             = "example-db-endpoint.rds.amazonaws.com"
PORT                = "3306"
MYSQL_ROOT_PASSWORD = "CHANGE_ME"

# SMTP
SMTP_API_KEY    = "smtp_user@example.com"
SMTP_PASSWORD   = "CHANGE_ME"
SMTP_FROM_EMAIL = "noreply@example.com"
SMTP_SERVER     = "smtp.example.com"
SMTP_PORT       = "587"

# JWT
JWT_SECRET_KEY = "CHANGE_ME"
JWT_ALGORITHM  = "HS256"




### Step 3: Deploy Infrastructure with Terraform

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan the deployment
terraform plan -var-file=terraform.tfvars

# Apply the changes
terraform apply -var-file=terraform.tfvars
```

This will create:
- VPC with public/private subnets
- EKS cluster with managed node groups
- RDS MySQL instance
- ECR repository
- Secrets Manager secrets
- IAM roles and policies
- Security groups

### Step 4: Build and Push Docker Image

```bash
# Navigate to the image directory
cd project

# Build the Docker image
docker build -t my-python-app:latest .

# Get ECR login token and login
aws ecr get-login-password --region <your-region> | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.<your-region>.amazonaws.com

# Tag the image for ECR
docker tag my-python-app:latest <account-id>.dkr.ecr.<your-region>.amazonaws.com/my-python-app:latest

# Push to ECR
docker push <account-id>.dkr.ecr.<your-region>.amazonaws.com/my-python-app:latest
```

### Step 5: Configure kubectl

```bash
# Update kubeconfig
aws eks update-kubeconfig --region <your-region> --name <cluster-name>

# Verify cluster access
kubectl get nodes
```

### Step 6: Deploy Kubernetes Resources

```bash
# Navigate to k8s manifests directory
cd ../k8

# Apply manifests in order
kubectl apply -f namespace.yaml
kubectl apply -f service-account.yaml
kubectl apply -f secrets-provider-class.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml
kubectl apply -f ingress.yaml
```

### Step 7: Verify Deployment

```bash
# Check pod status
kubectl get pods -n production

# Check HPA status
kubectl get hpa -n production

# Check ingress
kubectl get ingress -n production

# Get ALB endpoint
kubectl get ingress -n production -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
```

---

## 🔧 Configuration


### Autoscaling Configuration

#### Horizontal Pod Autoscaler (HPA)
- **Metric**: CPU utilization
- **Target**: 70%
- **Min Replicas**: 2
- **Max Replicas**: 10

#### Cluster Autoscaler
- **Min Nodes**: 1
- **Max Nodes**: 5
- **Scale down**: After 10 minutes of low utilization

### SSL/TLS Configuration

The setup automatically provisions SSL certificates via ACM. Update the domain in your `terraform.tfvars` file:

```hcl
domain_name = "your-domain.com"
```

---



## 🔒 Security Best Practices

This setup implements several security best practices:

1. **Network Security**
   - EKS cluster in private subnets
   - Security groups with minimal required access
   - No direct internet access to worker nodes

2. **Secrets Management**
   - Database passwords stored in AWS Secrets Manager
   - Secrets mounted into pods via CSI driver
   - No hardcoded credentials in code or manifests

3. **IAM Security**
   - Least privilege IAM roles
   - IRSA (IAM Roles for Service Accounts) for pod-level permissions
   - No long-term access keys

4. **Transport Security**
   - HTTPS termination at ALB
   - SSL certificates managed by ACM

---

## 🚨 Troubleshooting

### Common Issues

1. **Pods not starting**
   ```bash
   kubectl describe pod <pod-name> -n my-python-app
   kubectl logs <pod-name> -n my-python-app
   ```

2. **ALB not accessible**
   - Check security groups
   - Verify ACM certificate status
   - Check ingress annotations

3. **Database connection issues**
   - Verify RDS security group allows EKS access
   - Check secrets in Secrets Manager
   - Validate database endpoint resolution

4. **HPA not scaling**
   ```bash
   kubectl describe hpa -n production
   kubectl top pods -n production
   ```



## 🧹 Cleanup

To avoid ongoing AWS charges, destroy the resources when no longer needed:

```bash
# Delete Kubernetes resources
kubectl delete -f k8/

# Destroy Terraform infrastructure
cd project
terraform destroy -var-file=terraform.tfvars
```

**Note**: Ensure you've deleted any persistent volumes or load balancers that might have been created outside of Terraform.

---





## 📚 Additional Resources

- [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS Load Balancer Controller Documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/)

---

⭐ If this project helped you, please give it a star! ⭐