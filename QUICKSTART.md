# Quick Start Guide - GitHub Actions & Checkov

## 🚀 5 phút để setup hoàn chỉnh

### Bước 1: Push code lên GitHub (2 phút)

```bash
cd /Users/thangtiennguyen/Documents/Cursor/project/NT548/iac-vprofile

# Initialize git (nếu chưa có)
git init

# Add remote
git remote add origin https://github.com/YOUR_USERNAME/iac-vprofile.git

# Add files
git add .
git commit -m "feat: Add Terraform with GitHub Actions and Checkov"

# Push
git push -u origin main
```

### Bước 2: Cấu hình GitHub Secrets (2 phút)

1. Vào: `https://github.com/YOUR_USERNAME/iac-vprofile/settings/secrets/actions`
2. Click **"New repository secret"**
3. Thêm 2 secrets:

   **Secret 1: AWS_ACCESS_KEY_ID**
   ```
   Value: YOUR_AWS_ACCESS_KEY_ID
   ```

   **Secret 2: AWS_SECRET_ACCESS_KEY**
   ```
   Value: YOUR_AWS_SECRET_ACCESS_KEY
   ```

### Bước 3: Enable GitHub Actions (30 giây)

1. Vào tab **Actions** trong repository
2. Click **"I understand my workflows, go ahead and enable them"**
3. Done! ✅

### Bước 4: Test workflow (30 giây)

**Option A: Tạo Pull Request**
```bash
git checkout -b test/checkov-scan
git commit --allow-empty -m "test: Trigger Checkov scan"
git push origin test/checkov-scan
```

Tạo PR trên GitHub → Checkov sẽ tự động chạy và comment kết quả!

**Option B: Manual trigger**
1. Vào tab **Actions**
2. Chọn workflow **"Terraform CI/CD with Checkov Security Scan"**
3. Click **"Run workflow"**
4. Select branch **main**
5. Click **"Run workflow"**

---

## 📊 Expected Results

### Sau khi push code hoặc tạo PR:

1. **Security Scan** (~2 phút)
   ```
   ✅ Checkov scan completed
   📊 Passed: 300+ checks
   ⚠️  Failed: 30-40 checks (mostly from external modules)
   ```

2. **Terraform Plan** (~3 phút)
   ```
   ✅ Format check passed
   ✅ Init successful
   ✅ Validation passed
   ✅ Plan created
   ```

3. **PR Comment** (automatic)
   ```
   GitHub bot sẽ comment vào PR với:
   - Checkov security results
   - Terraform plan preview
   - Cost estimation (nếu configured)
   ```

---

## 🎯 What's automated?

| Event | What Happens | Time |
|-------|-------------|------|
| Push to `main` | ✅ Security scan<br>✅ Terraform plan<br>✅ Terraform apply | ~15 min |
| Push to `develop` | ✅ Security scan<br>✅ Terraform plan | ~5 min |
| Pull Request | ✅ Security scan<br>✅ Terraform plan<br>✅ PR comment | ~5 min |
| Manual trigger | Custom action | Varies |

---

## 📁 Files Created

```
iac-vprofile/
├── .github/workflows/
│   ├── terraform.yml           ← Main CI/CD workflow
│   ├── checkov-pr.yml          ← PR security checks
│   └── terraform-destroy.yml   ← Destroy workflow
├── .checkov.yml                ← Checkov configuration
├── .gitignore                  ← Ignore sensitive files
├── scripts/
│   └── checkov-scan.sh         ← Local testing script
├── docs/
│   └── GITHUB_ACTIONS_SETUP.md ← Detailed guide
└── terraform/
    ├── *.tf files              ← Your infrastructure code
    └── terraform.tfvars.example

```

---

## 🧪 Test locally trước khi push

```bash
cd iac-vprofile

# 1. Format check
cd terraform && terraform fmt -check -recursive

# 2. Validate
terraform init
terraform validate

# 3. Security scan
cd .. && ./scripts/checkov-scan.sh

# 4. Plan
cd terraform && terraform plan
```

---

## 🔒 Security Features

✅ **Checkov scanning**
- 500+ security checks
- Infrastructure as Code best practices
- Compliance validation (CIS, PCI-DSS, HIPAA)

✅ **GitHub Security**
- Secrets encrypted at rest
- No sensitive data in logs
- Environment protection rules

✅ **AWS Security**
- IAM least privilege
- Security group rules validated
- Encryption checks

---

## 💡 Tips

1. **First deployment will take ~15 minutes**
   - EKS cluster creation: ~10 min
   - NAT Gateway: ~2 min
   - Other resources: ~3 min

2. **Failed Checkov checks are OK for dev**
   - Many failures come from external modules
   - Review and skip with justification if needed

3. **Use branch protection**
   ```
   Settings → Branches → Add rule
   ✅ Require pull request reviews
   ✅ Require status checks to pass
   ✅ Require branches to be up to date
   ```

4. **Monitor workflow costs**
   - Free tier: 2,000 minutes/month
   - This setup: ~10-15 minutes per deployment
   - ~100-150 deploys per month on free tier

---

## 🐛 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Workflow not running | Check Actions tab → Enable workflows |
| AWS credentials error | Verify secrets in Settings → Secrets |
| Checkov failures | Review with `./scripts/checkov-scan.sh` |
| Terraform state locked | Wait 20 min or run `terraform force-unlock` |

---

## 📚 Next Steps

1. ✅ **Review Checkov results**
   ```bash
   ./scripts/checkov-scan.sh
   ```

2. ✅ **Configure environment protection**
   - Settings → Environments → Add "production"
   - Add required reviewers

3. ✅ **Setup notifications** (optional)
   - Add Slack webhook
   - Email notifications

4. ✅ **Document your changes**
   - Update README with your specifics
   - Add architecture diagrams

---

## ⚡ Ready to deploy!

```bash
# Method 1: Via Git
git push origin main

# Method 2: Via GitHub UI
Actions → Terraform CI/CD → Run workflow

# Monitor progress
Actions → Click on running workflow → View logs
```

---

**🎉 Congratulations! Your infrastructure is now fully automated!**

**Need help?** Check `docs/GITHUB_ACTIONS_SETUP.md` for detailed guide.

