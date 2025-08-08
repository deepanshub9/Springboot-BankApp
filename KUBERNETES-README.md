# ☸️ Kubernetes Setup & Deployment Guide

![Kubernetes](https://img.shields.io/badge/Kubernetes-1.32+-blue)
![AWS EKS](https://img.shields.io/badge/AWS%20EKS-Supported-orange)
![Helm](https://img.shields.io/badge/Helm-3.18+-brightgreen)
![ArgoCD](https://img.shields.io/badge/ArgoCD-Enabled-purple)
![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-red)

A comprehensive guide for deploying and managing the Spring Boot Banking Application on Kubernetes with enterprise-grade features including CI/CD, monitoring, security, and scalability.

## 🎯 Overview

This Kubernetes setup provides a complete cloud-native deployment solution featuring:
- **Container Orchestration**: Full Kubernetes deployment with high availability
- **GitOps Workflow**: ArgoCD for continuous deployment
- **Monitoring Stack**: Prometheus + Grafana for observability
- **Service Mesh**: Ingress-based traffic management
- **Security**: SSL/TLS certificates with cert-manager
- **Scalability**: Horizontal Pod Autoscaling (HPA)
- **Storage**: Persistent volume management with AWS EBS

## 🏗️ Architecture Overview

### Infrastructure Components
- **EKS Cluster**: Managed Kubernetes on AWS
- **Worker Nodes**: EC2 instances with auto-scaling groups
- **Load Balancer**: AWS Application Load Balancer
- **Storage**: AWS EBS CSI driver for persistent volumes
- **Networking**: VPC with private/public subnets

### Application Stack
- **Frontend/Backend**: Spring Boot Banking Application
- **Database**: MySQL with persistent storage
- **Reverse Proxy**: Nginx Ingress Controller
- **TLS Termination**: Cert-manager with Let's Encrypt
- **Service Discovery**: Kubernetes DNS

### Monitoring & Observability
- **Metrics**: Prometheus for metrics collection
- **Visualization**: Grafana dashboards
- **Logging**: ELK stack integration (optional)
- **Tracing**: Jaeger integration (optional)
- **Health Checks**: Kubernetes probes + custom health endpoints

## 📋 Prerequisites

### Required Tools & Versions
- **kubectl**: v1.33+ (Kubernetes CLI)
- **helm**: v3.18+ (Package manager)
- **aws-cli**: v2.0+ (AWS command line interface)
- **eksctl**: v0.150+ (EKS cluster management)
- **terraform**: v1.0+ (Infrastructure as Code) - Optional
- **docker**: v20.10+ (Container runtime)
- **git**: Latest version

### AWS Requirements
- **AWS Account**: With appropriate permissions
- **IAM Roles**: EKS cluster and node group roles
- **VPC**: Configured with public/private subnets
- **Security Groups**: Properly configured for EKS
- **Route53**: For DNS management (optional)

### Local Environment
- **Operating System**: Linux, macOS, or Windows with WSL2
- **Memory**: Minimum 8GB RAM, Recommended 16GB+
- **Storage**: At least 20GB free space
- **Network**: Stable internet connection for cluster communication

## 🚀 Initial Setup

### 1. Install Required Tools

#### Install kubectl
```bash
# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# macOS
brew install kubectl

# Verify installation
kubectl version --client
```

#### Install Helm
```bash
# Linux/macOS
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

#### Install AWS CLI
```bash
# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI
aws configure
```

#### Install eksctl
```bash
# Linux
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Verify installation
eksctl version
```

### 2. AWS Configuration

#### Configure AWS Credentials
```bash
# Set up AWS credentials
aws configure set aws_access_key_id YOUR_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_SECRET_KEY
aws configure set default.region us-east-1
aws configure set default.output json

# Verify configuration
aws sts get-caller-identity
```

#### Create IAM Roles (if not exists)
```bash
# EKS Cluster Service Role
aws iam create-role --role-name eksServiceRole \
  --assume-role-policy-document file://cluster-trust-policy.json

# EKS Node Group Role
aws iam create-role --role-name eksNodeGroupRole \
  --assume-role-policy-document file://node-trust-policy.json
```

## 🏭 EKS Cluster Creation

### Method 1: Using eksctl (Recommended)

#### Create Cluster Configuration
```yaml
# cluster-config.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: bankapp-cluster
  region: us-east-1
  version: "1.32"

availabilityZones: ["us-east-1a", "us-east-1b", "us-east-1c"]

managedNodeGroups:
  - name: bankapp-workers
    instanceType: t3.medium
    desiredCapacity: 3
    minSize: 2
    maxSize: 5
    privateNetworking: true
    volumeSize: 20
    volumeType: gp3
    iam:
      withAddonPolicies:
        ebs: true
        efs: true
        albIngress: true
        cloudWatch: true

addons:
  - name: vpc-cni
    version: latest
  - name: coredns
    version: latest
  - name: kube-proxy
    version: latest
  - name: aws-ebs-csi-driver
    version: latest

iam:
  withOIDC: true
  serviceAccounts:
    - metadata:
        name: aws-load-balancer-controller
        namespace: kube-system
      wellKnownPolicies:
        awsLoadBalancerController: true
    - metadata:
        name: ebs-csi-controller-sa
        namespace: kube-system
      wellKnownPolicies:
        ebsCSIController: true
    - metadata:
        name: cert-manager
        namespace: cert-manager
      wellKnownPolicies:
        certManager: true
```

#### Deploy EKS Cluster
```bash
# Create cluster
eksctl create cluster -f cluster-config.yaml

# Verify cluster creation
kubectl get nodes
kubectl get pods --all-namespaces

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name bankapp-cluster
```

### Method 2: Using Terraform

#### Terraform Configuration
```bash
# Initialize Terraform
cd terraform/
terraform init

# Plan infrastructure
terraform plan -var="cluster_name=bankapp-cluster"

# Apply configuration
terraform apply -auto-approve

# Get kubeconfig
aws eks update-kubeconfig --region us-east-1 --name bankapp-cluster
```

## 📦 Core Components Installation

### 1. Install Essential Add-ons

#### AWS Load Balancer Controller
```bash
# Add EKS Helm repository
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=bankapp-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

#### Metrics Server
```bash
# Install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify installation
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
```

### 2. Install Ingress Controller

#### Nginx Ingress Controller
```bash
# Add ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install Nginx Ingress Controller
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="nlb" \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-cross-zone-load-balancing-enabled"="true"

# Verify installation
kubectl get pods -n ingress-nginx
kubectl get service -n ingress-nginx
```

### 3. Install Cert-Manager

#### SSL Certificate Management
```bash
# Add cert-manager repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.0 \
  --set installCRDs=true \
  --set serviceAccount.create=false \
  --set serviceAccount.name=cert-manager

# Verify installation
kubectl get pods -n cert-manager
```

#### Configure Let's Encrypt ClusterIssuer
```bash
# Create Let's Encrypt ClusterIssuer
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
