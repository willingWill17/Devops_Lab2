# Deployment Checklist ✅

## Pre-Deployment (Chuẩn bị)

### 1. Tools Installation
- [ ] Terraform >= 1.5.0 installed
  ```bash
  terraform version
  ```
- [ ] AWS CLI v2.x installed
  ```bash
  aws --version
  ```
- [ ] Checkov installed (optional for local testing)
  ```bash
  pip install checkov
  ```
- [ ] Git installed
  ```bash
  git --version
  ```

### 2. AWS Setup
- [ ] AWS Account created
- [ ] IAM user created với appropriate permissions:
  - [ ] EC2 Full Access
  - [ ] VPC Full Access
  - [ ] EKS Admin Access
  - [ ] S3 Full Access
  - [ ] IAM Full Access
- [ ] AWS credentials configured locally
  ```bash
  aws configure
  aws sts get-caller-identity
  ```
- [ ] S3 bucket for Terraform state created (nếu dùng remote backend)
  ```bash
  aws s3 mb s3://vprofileactions0811
  ```

### 3. SSH Keys
- [ ] SSH key pair generated
  ```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/vprofile-key
  ```
- [ ] Public key copied
  ```bash
  cat ~/.ssh/vprofile-key.pub
  ```

### 4. Code Preparation
- [ ] Repository cloned
  ```bash
  git clone <repo-url>
  cd iac-vprofile
  ```
- [ ] `terraform.tfvars` created từ example
  ```bash
  cd terraform
  cp terraform.tfvars.example terraform.tfvars
  ```
- [ ] `terraform.tfvars` configured với values của bạn:
  - [ ] `ssh_public_key` updated
  - [ ] `region` confirmed
  - [ ] `project_name` set
  - [ ] `allowed_ssh_cidr_blocks` restricted (không dùng 0.0.0.0/0 cho production!)

---

## Local Testing (Test trước)

### 1. Terraform Checks
- [ ] Format check
  ```bash
  cd terraform
  terraform fmt -check -recursive
  ```
- [ ] Initialize Terraform
  ```bash
  terraform init
  ```
- [ ] Validate configuration
  ```bash
  terraform validate
  ```
- [ ] Generate plan
  ```bash
  terraform plan -out=tfplan
  ```
- [ ] Review plan output
  - [ ] Check resources to be created
  - [ ] Verify no unexpected changes
  - [ ] Confirm costs acceptable

### 2. Security Scan
- [ ] Run Checkov locally
  ```bash
  cd ..
  ./scripts/checkov-scan.sh
  ```
- [ ] Review failed checks
- [ ] Address critical issues
- [ ] Document skipped checks với justification

### 3. Code Review
- [ ] No hardcoded secrets
- [ ] No sensitive data in code
- [ ] Variables properly used
- [ ] Outputs defined
- [ ] Comments added where needed
- [ ] .gitignore configured
- [ ] No *.tfstate files in repo

---

## GitHub Setup (Nếu dùng GitHub Actions)

### 1. Repository Setup
- [ ] Repository created trên GitHub
- [ ] Code pushed to repository
  ```bash
  git remote add origin <github-url>
  git push -u origin main
  ```

### 2. Secrets Configuration
- [ ] Vào Settings → Secrets and variables → Actions
- [ ] Add `AWS_ACCESS_KEY_ID`
- [ ] Add `AWS_SECRET_ACCESS_KEY`
- [ ] Verify secrets are set (không thấy values nhưng names visible)

### 3. Workflows Configuration
- [ ] Workflows files exist trong `.github/workflows/`
- [ ] YAML syntax valid
  ```bash
  yamllint .github/workflows/*.yml
  ```
- [ ] Workflows enabled trong Actions tab

### 4. Environment Protection (Optional but recommended)
- [ ] Vào Settings → Environments
- [ ] Create `production` environment
- [ ] Add required reviewers
- [ ] Configure deployment branch (main only)

### 5. Branch Protection (Recommended)
- [ ] Vào Settings → Branches → Branch protection rules
- [ ] Protect `main` branch
- [ ] Require pull request reviews
- [ ] Require status checks to pass
- [ ] Require branches to be up to date

---

## Deployment

### Option A: Manual Deployment

#### 1. Apply Infrastructure
- [ ] Apply Terraform plan
  ```bash
  cd terraform
  terraform apply tfplan
  ```
- [ ] Monitor creation progress (~15-20 minutes)
- [ ] Verify no errors
- [ ] Note down outputs
  ```bash
  terraform output
  ```

#### 2. Verify Resources
- [ ] Check VPC created
  ```bash
  aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*vprofile*"
  ```
- [ ] Check EC2 instances running
  ```bash
  aws ec2 describe-instances --filters "Name=tag:Project,Values=vprofile"
  ```
- [ ] Check EKS cluster active
  ```bash
  aws eks describe-cluster --name gitopsProject-eks
  ```
- [ ] Check security groups configured
  ```bash
  aws ec2 describe-security-groups --filters "Name=tag:Project,Values=vprofile"
  ```

### Option B: GitHub Actions Deployment

#### 1. Trigger Workflow
- [ ] Method 1: Push to main
  ```bash
  git push origin main
  ```
- [ ] OR Method 2: Manual trigger từ Actions tab
- [ ] OR Method 3: Create và merge PR

#### 2. Monitor Workflow
- [ ] Vào Actions tab
- [ ] Click vào running workflow
- [ ] Monitor each job:
  - [ ] Security scan passes
  - [ ] Terraform plan succeeds
  - [ ] Terraform apply completes (if main branch)

#### 3. Review Results
- [ ] Check workflow logs
- [ ] Download artifacts (plan, reports)
- [ ] Review PR comments (if PR)
- [ ] Verify infrastructure created

---

## Post-Deployment Verification

### 1. SSH Access
- [ ] SSH to Bastion host works
  ```bash
  ssh -i ~/.ssh/vprofile-key ec2-user@<bastion_public_ip>
  ```
- [ ] SSH to App server via Bastion works
  ```bash
  ssh -i ~/.ssh/vprofile-key -J ec2-user@<bastion_public_ip> ec2-user@<app_private_ip>
  ```

### 2. Network Connectivity
- [ ] Internet Gateway working
- [ ] NAT Gateway routing traffic
- [ ] Private subnets can reach internet via NAT
  ```bash
  # From app server
  curl -I https://www.google.com
  ```

### 3. EKS Cluster
- [ ] Update kubeconfig
  ```bash
  aws eks update-kubeconfig --name gitopsProject-eks --region us-east-1
  ```
- [ ] List nodes
  ```bash
  kubectl get nodes
  ```
- [ ] All nodes in Ready state
- [ ] Deploy test application (optional)
  ```bash
  kubectl run nginx --image=nginx
  kubectl get pods
  ```

### 4. Security Verification
- [ ] Security groups có correct rules
- [ ] No unnecessary ports open
- [ ] Bastion only accessible from allowed IPs
- [ ] App server không có public IP
- [ ] NAT Gateway in public subnet

### 5. Cost Monitoring
- [ ] Set up billing alerts
- [ ] Check AWS Cost Explorer
- [ ] Confirm costs match estimates (~$200/month)

---

## Documentation

### 1. Update Documentation
- [ ] README updated with actual values
- [ ] Architecture diagram reflects reality
- [ ] Outputs documented
- [ ] Known issues noted

### 2. Record Information
- [ ] Bastion public IP: ________________
- [ ] App server private IP: ________________
- [ ] EKS cluster endpoint: ________________
- [ ] VPC ID: ________________
- [ ] NAT Gateway ID: ________________

### 3. Create Runbook
- [ ] SSH access procedures
- [ ] Emergency procedures
- [ ] Backup/restore procedures
- [ ] Monitoring setup

---

## Maintenance

### 1. Regular Tasks
- [ ] Review security groups monthly
- [ ] Rotate SSH keys quarterly
- [ ] Update Terraform providers
- [ ] Patch EC2 instances
- [ ] Review AWS bills

### 2. Monitoring Setup
- [ ] CloudWatch alarms configured
- [ ] Log aggregation setup
- [ ] Alerting configured
- [ ] Dashboard created

### 3. Backup & DR
- [ ] Terraform state backed up
- [ ] EBS snapshots scheduled
- [ ] Disaster recovery plan documented
- [ ] Recovery tested

---

## Cleanup (Khi muốn xóa)

### 1. Pre-Cleanup
- [ ] Backup important data
- [ ] Export configurations
- [ ] Document lessons learned
- [ ] Save Terraform state

### 2. Destroy Infrastructure

**Option A: Via Terraform**
```bash
cd terraform
terraform destroy -auto-approve
```

**Option B: Via GitHub Actions**
- [ ] Go to Actions tab
- [ ] Select "Terraform Destroy" workflow
- [ ] Click "Run workflow"
- [ ] Type "destroy" to confirm
- [ ] Select environment
- [ ] Confirm destroy

### 3. Post-Cleanup
- [ ] Verify all resources deleted
  ```bash
  aws ec2 describe-instances --filters "Name=tag:Project,Values=vprofile"
  aws eks list-clusters
  aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*vprofile*"
  ```
- [ ] Check for orphaned resources
- [ ] Delete S3 state bucket (if no longer needed)
- [ ] Remove SSH keys
- [ ] Update documentation

---

## Troubleshooting Checklist

### Common Issues

#### AWS Credentials Error
- [ ] Check `~/.aws/credentials`
- [ ] Verify IAM permissions
- [ ] Test with: `aws sts get-caller-identity`

#### Terraform State Locked
- [ ] Wait 20 minutes for timeout
- [ ] Force unlock: `terraform force-unlock <lock-id>`
- [ ] Check for zombie processes

#### Security Group Issues
- [ ] Verify CIDR blocks correct
- [ ] Check dependencies between SGs
- [ ] Review AWS console for errors

#### EKS Creation Failed
- [ ] Verify IAM role has eks:CreateCluster
- [ ] Check subnet requirements (min 2 AZs)
- [ ] Review CloudWatch logs

#### Checkov Failures
- [ ] Run locally: `./scripts/checkov-scan.sh`
- [ ] Review specific check IDs
- [ ] Skip with justification if needed
- [ ] Update .checkov.yml config

#### GitHub Actions Not Running
- [ ] Verify workflows enabled
- [ ] Check workflow syntax
- [ ] Review branch/path filters
- [ ] Check secrets configured

---

## Success Criteria

### Infrastructure
- [x] VPC created với 3 AZs
- [x] 6 subnets (3 public + 3 private)
- [x] Internet Gateway attached
- [x] NAT Gateway in public subnet
- [x] Route tables configured
- [x] Bastion host accessible
- [x] App server in private subnet
- [x] EKS cluster running
- [x] 3 worker nodes active
- [x] Security groups configured

### CI/CD
- [x] GitHub Actions workflows created
- [x] Secrets configured
- [x] Workflows trigger correctly
- [x] Checkov scan runs
- [x] Terraform plan generates
- [x] PR comments work
- [x] Artifacts uploaded

### Security
- [x] No hardcoded secrets
- [x] Checkov scan passing (with acceptable failures)
- [x] Security groups follow least privilege
- [x] IMDSv2 enabled
- [x] EBS encryption enabled
- [x] No public IPs on app servers

### Documentation
- [x] README complete
- [x] Architecture diagram created
- [x] Quick start guide available
- [x] Troubleshooting guide included

---

## Final Sign-off

- [ ] All checklist items completed
- [ ] Infrastructure verified working
- [ ] Documentation complete
- [ ] Team trained
- [ ] Handover complete

**Deployed by**: _____________________

**Date**: _____________________

**Signature**: _____________________

---

## Notes

```
Ghi chú, issues, hoặc observations trong quá trình deployment:






```

---

**🎉 Congratulations on successful deployment!**

