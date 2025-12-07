# Terraform AWS Infrastructure - VProfile Project

## 📋 Mục lục

- [Tổng quan](#-tổng-quan)
- [Kiến trúc hạ tầng](#-kiến-trúc-hạ-tầng)
- [Yêu cầu](#-yêu-cầu)
- [Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [Cài đặt và cấu hình](#-cài-đặt-và-cấu-hình)
- [Triển khai thủ công](#-triển-khai-thủ-công)
- [Tự động hóa với GitHub Actions](#-tự-động-hóa-với-github-actions)
- [Checkov Security Scanning](#-checkov-security-scanning)
- [Outputs](#-outputs)

---

## 🎯 Tổng quan

Dự án này triển khai hạ tầng AWS sử dụng Terraform, bao gồm:

- **VPC** với Public/Private Subnets
- **NAT Gateway** cho private subnet access
- **Route Tables** được cấu hình tự động
- **EC2 Instances** (Bastion Host & Application Server)
- **Security Groups** với các quy tắc bảo mật chặt chẽ
- **EKS Cluster** cho Kubernetes workloads

### Tính năng CI/CD

- ✅ **GitHub Actions** tự động hóa triển khai
- ✅ **Checkov** kiểm tra bảo mật và tuân thủ
- ✅ **Terraform Plan** review trước khi apply
- ✅ **Infrastructure as Code** best practices

---

## 🏗 Kiến trúc hạ tầng

```
┌─────────────────────────────────────────────────────────────────┐
│                           AWS Cloud                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                        VPC (172.20.0.0/16)                 │  │
│  │                                                            │  │
│  │   ┌─────────────────┐       ┌─────────────────┐          │  │
│  │   │  Public Subnet   │       │  Public Subnet   │          │  │
│  │   │  172.20.4.0/24   │       │  172.20.5.0/24   │          │  │
│  │   │                  │       │                  │          │  │
│  │   │  ┌──────────┐   │       │                  │          │  │
│  │   │  │ Bastion  │   │       │  ┌───────────┐  │          │  │
│  │   │  │   Host   │   │       │  │    NAT    │  │          │  │
│  │   │  └──────────┘   │       │  │  Gateway  │  │          │  │
│  │   └────────┬────────┘       └───────┬───────┘          │  │
│  │            │                        │                    │  │
│  │   ┌────────▼────────┐       ┌───────▼───────┐          │  │
│  │   │ Private Subnet  │       │ Private Subnet │          │  │
│  │   │ 172.20.1.0/24   │       │ 172.20.2.0/24  │          │  │
│  │   │                 │       │                │          │  │
│  │   │  ┌──────────┐  │       │  ┌──────────┐ │          │  │
│  │   │  │   App    │  │       │  │   EKS    │ │          │  │
│  │   │  │  Server  │  │       │  │  Nodes   │ │          │  │
│  │   │  └──────────┘  │       │  └──────────┘ │          │  │
│  │   └────────────────┘       └───────────────┘          │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 Yêu cầu

### Tools cần thiết

| Tool | Phiên bản | Mục đích |
|------|-----------|----------|
| Terraform | >= 1.5.0 | Infrastructure as Code |
| AWS CLI | v2.x | AWS authentication |
| Checkov | Latest | Security scanning |
| Git | Latest | Version control |

### AWS Requirements

- AWS Account với IAM credentials
- S3 Bucket cho Terraform state (`vprofileactions0811`)
- IAM permissions cho VPC, EC2, EKS, S3

---

## 📂 Cấu trúc thư mục

```
iac-vprofile/
├── .github/
│   └── workflows/
│       ├── terraform.yml       # Main deployment workflow
│       └── checkov-pr.yml      # PR security check
├── terraform/
│   ├── main.tf                 # Main configuration & providers
│   ├── vpc.tf                  # VPC, Subnets, NAT Gateway
│   ├── eks-cluster.tf          # EKS Cluster configuration
│   ├── ec2.tf                  # EC2 instances (Bastion, App)
│   ├── security-groups.tf      # Security Groups
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── terraform.tf            # Terraform & provider versions
│   └── terraform.tfvars.example # Example variables file
├── .checkov.yaml               # Checkov configuration
├── .gitignore                  # Git ignore patterns
└── README.md                   # This file
```

---

## ⚙️ Cài đặt và cấu hình

### 1. Clone repository

```bash
git clone <repository-url>
cd iac-vprofile
```

### 2. Cấu hình AWS credentials

```bash
# Option 1: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"

# Option 2: AWS CLI profile
aws configure --profile vprofile
export AWS_PROFILE=vprofile
```

### 3. Tạo SSH key pair

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/vprofile-key -N ""
```

### 4. Cấu hình Terraform variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars với các giá trị của bạn
# Đặc biệt quan trọng: ssh_public_key
```

---

## 🚀 Triển khai thủ công

### Các bước triển khai

```bash
cd terraform

# 1. Initialize Terraform
terraform init

# 2. Format check
terraform fmt -check

# 3. Validate configuration
terraform validate

# 4. Preview changes
terraform plan -out=tfplan

# 5. Apply changes
terraform apply -auto-approve -input=false tfplan

# 6. View outputs
terraform output
```

### Xóa hạ tầng

```bash
terraform destroy -auto-approve
```

---

## 🔄 Tự động hóa với GitHub Actions

### Cấu hình Secrets

Thêm các secrets sau vào GitHub repository:

| Secret Name | Mô tả |
|-------------|-------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key |
| `SSH_PUBLIC_KEY` | Public SSH key cho EC2 |

**Cách thêm secrets:**
1. Vào Repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Thêm từng secret

### Workflow Triggers

| Event | Action |
|-------|--------|
| Push to `main` | Plan → Apply |
| Push to `develop` | Plan only |
| Pull Request | Checkov + Plan + Comment |
| Manual trigger | Plan/Apply/Destroy |

### Workflow Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Checkov   │ ──▶ │   Validate   │ ──▶ │    Plan     │
│    Scan     │     │  fmt + init  │     │             │
└─────────────┘     └──────────────┘     └──────┬──────┘
                                                 │
                                                 ▼
                                          ┌─────────────┐
                                          │    Apply    │
                                          │ (main only) │
                                          └─────────────┘
```

### Manual Deployment

1. Vào tab **Actions** trong GitHub
2. Chọn workflow **Terraform Infrastructure Deployment**
3. Click **Run workflow**
4. Chọn action: `plan`, `apply`, hoặc `destroy`

---

## 🛡 Checkov Security Scanning

### Chạy Checkov locally

```bash
# Install Checkov
pip install checkov

# Run scan
checkov -d terraform/ --framework terraform

# With specific checks
checkov -d terraform/ --check CKV_AWS_1,CKV_AWS_2

# Soft fail mode
checkov -d terraform/ --soft-fail
```

### Các check quan trọng

| Check ID | Mô tả |
|----------|-------|
| CKV_AWS_8 | EC2 có encrypted EBS |
| CKV_AWS_79 | EC2 dùng IMDSv2 |
| CKV_AWS_88 | EC2 có public IP hợp lý |
| CKV_AWS_23 | Security Group có description |
| CKV_AWS_24 | Security Group không cho SSH từ 0.0.0.0/0 |

### Skip specific checks

Thêm comment trong Terraform code:

```hcl
resource "aws_security_group" "example" {
  #checkov:skip=CKV_AWS_24: Bastion host cần SSH access từ internet
  ...
}
```

---

## 📤 Outputs

Sau khi triển khai, các outputs sau sẽ được hiển thị:

| Output | Mô tả |
|--------|-------|
| `cluster_name` | Tên EKS cluster |
| `cluster_endpoint` | EKS API endpoint |
| `vpc_id` | VPC ID |
| `bastion_public_ip` | Public IP của Bastion host |
| `app_server_private_ip` | Private IP của App server |

### Kết nối SSH

```bash
# SSH vào Bastion host
ssh -i ~/.ssh/vprofile-key ec2-user@<bastion_public_ip>

# SSH vào App server qua Bastion (SSH tunnel)
ssh -i ~/.ssh/vprofile-key -J ec2-user@<bastion_public_ip> ec2-user@<app_server_private_ip>
```

### Kết nối EKS

```bash
# Update kubeconfig
aws eks update-kubeconfig --name gitopsProject-eks --region us-east-1

# Verify connection
kubectl get nodes
```

---

## 🔧 Troubleshooting

### Lỗi thường gặp

1. **S3 Backend Error**
   ```bash
   # Tạo S3 bucket cho state
   aws s3 mb s3://vprofileactions0811 --region us-east-1
   ```

2. **Permission Denied**
   - Kiểm tra IAM policies
   - Verify AWS credentials

3. **Checkov Failures**
   - Review security best practices
   - Skip với justification nếu cần

### Logs và Debug

```bash
# Terraform debug
export TF_LOG=DEBUG
terraform plan

# AWS CLI debug
aws sts get-caller-identity
```

---

## 📚 Tài liệu tham khảo

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Checkov Documentation](https://www.checkov.io/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)

---

## 👥 Contributors

- VProfile DevOps Team

## 📄 License

MIT License
