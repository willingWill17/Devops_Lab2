# AWS Credentials Troubleshooting Guide

## ✅ Checklist - Verify Secrets Setup

### Step 1: Verify Secret Names (EXACT match!)

Trong GitHub Secrets, tên phải CHÍNH XÁC:
- ✅ `AWS_ACCESS_KEY_ID` (không có spaces, đúng case)
- ✅ `AWS_SECRET_ACCESS_KEY` (không có spaces, đúng case)

**Check:**
1. Vào: `https://github.com/willingWill17/Devops_Lab2/settings/secrets/actions`
2. Xem danh sách secrets
3. Verify tên chính xác (case-sensitive!)

### Step 2: Verify Secret Values Format

**✅ CORRECT:**
```
AWS_ACCESS_KEY_ID: AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**❌ WRONG:**
```
# NO quotes
"AWIA..."  ❌

# NO spaces
AKIA... [space]  ❌

# NO newlines
AKIA...
[newline]  ❌

# NO export prefix
export AWS_ACCESS_KEY_ID=AKIA...  ❌
```

### Step 3: Update Secrets (Step-by-step)

**For AWS_ACCESS_KEY_ID:**
1. Click vào secret `AWS_ACCESS_KEY_ID`
2. Click **"Update"** button
3. **DELETE** toàn bộ text cũ
4. Paste **ONLY** the key (20 chars, starts with AKIA)
5. **NO spaces before/after**
6. Click **"Update secret"**

**For AWS_SECRET_ACCESS_KEY:**
1. Click vào secret `AWS_SECRET_ACCESS_KEY`
2. Click **"Update"** button
3. **DELETE** toàn bộ text cũ
4. Paste **ONLY** the secret (40 chars)
5. **NO spaces before/after**
6. Click **"Update secret"**

### Step 4: Verify Credentials Work Locally

```bash
# Test với credentials mới
export AWS_ACCESS_KEY_ID="<your-key>"
export AWS_SECRET_ACCESS_KEY="<your-secret>"
export AWS_REGION="us-east-1"

# Test
aws sts get-caller-identity

# Should return:
# {
#     "UserId": "...",
#     "Account": "025988852673",
#     "Arn": "arn:aws:iam::025988852673:user/tao-person"
# }
```

**Nếu local FAIL → Credentials sai, cần tạo mới**
**Nếu local PASS → Problem là ở GitHub Secrets format**

### Step 5: Re-run Workflow

**Sau khi update secrets, BẮT BUỘC phải re-run:**

**Option A: Re-run failed workflow**
1. Vào Actions tab
2. Click vào failed workflow run
3. Click **"Re-run all jobs"** (top right)

**Option B: Push new commit**
```bash
# Any small change
echo "test" >> README.md
git add README.md
git commit -m "test: Re-run workflow after credentials update"
git push
```

**Option C: Manual trigger**
1. Actions tab → Select workflow
2. Run workflow → Re-run

### Step 6: Check Workflow Logs

Sau khi re-run, check logs:

```yaml
Run aws-actions/configure-aws-credentials@v4
```

**✅ SUCCESS:**
```
Configuring AWS credentials
AWS credentials configured successfully
Region: us-east-1
```

**❌ FAIL:**
```
Error: The security token included in the request is invalid.
```

---

## 🔍 Common Issues & Fixes

### Issue 1: Secret has trailing newline

**Symptom:** Credentials look correct but still fail

**Fix:**
1. Update secret
2. Delete ALL text
3. Type manually (don't paste)
4. Save

### Issue 2: Secret name typo

**Symptom:** Workflow can't find secret

**Fix:**
- Check exact spelling: `AWS_ACCESS_KEY_ID` (not `AWS_ACCESS_KEY`)
- Check case: All uppercase
- No underscores missing

### Issue 3: Old credentials cached

**Symptom:** Updated but still using old values

**Fix:**
- Re-run workflow (don't just re-trigger)
- Or wait 5 minutes for cache to clear

### Issue 4: Credentials expired/rotated

**Symptom:** Worked before, now fails

**Fix:**
```bash
# Check key status
aws iam list-access-keys --user-name tao-person

# Create new key
aws iam create-access-key --user-name tao-person
```

### Issue 5: Wrong account/region

**Symptom:** Credentials valid but wrong account

**Fix:**
- Verify account: `aws sts get-caller-identity`
- Verify region in workflow: `us-east-1`

---

## 🧪 Test Script

Tạo file `test-secrets.sh`:

```bash
#!/bin/bash

echo "🔍 Testing AWS Credentials..."

# Get from GitHub Secrets (copy-paste manually)
read -p "Enter AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
read -p "Enter AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_REGION="us-east-1"

echo ""
echo "1. Testing STS..."
aws sts get-caller-identity

if [ $? -eq 0 ]; then
    echo "✅ Credentials VALID!"
    echo ""
    echo "2. Testing EC2..."
    aws ec2 describe-vpcs --max-items 1 > /dev/null
    if [ $? -eq 0 ]; then
        echo "✅ EC2 permissions OK!"
    fi
else
    echo "❌ Credentials INVALID!"
    echo ""
    echo "Check:"
    echo "  - No spaces/newlines"
    echo "  - Correct format"
    echo "  - Key not expired"
    exit 1
fi
```

Run:
```bash
chmod +x test-secrets.sh
./test-secrets.sh
```

---

## 📝 Quick Fix Steps

1. ✅ **Verify secret names** (exact match)
2. ✅ **Update secrets** (delete old, paste new, no spaces)
3. ✅ **Test locally** (`aws sts get-caller-identity`)
4. ✅ **Re-run workflow** (don't just re-trigger)
5. ✅ **Check logs** (look for "configured successfully")

---

## 🆘 Still Not Working?

### Nuclear Option: Delete & Recreate Secrets

1. Delete both secrets
2. Create fresh secrets with new names
3. Update workflow to use new names
4. Or use same names but fresh values

### Alternative: Use AWS CLI in Workflow

```yaml
- name: Configure AWS
  run: |
    aws configure set aws_access_key_id ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws configure set aws_secret_access_key ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws configure set region us-east-1
```

---

**Most likely issue:** Secrets có trailing spaces/newlines. Delete và paste lại cẩn thận!

