# GitHub Workflow Permissions Fix

## Issue
```
RequestError [HttpError]: Resource not accessible by integration
status: 403
X-Accepted-GitHub-Permissions: issues=write; pull_requests=write
```

## Root Cause
GitHub Actions `GITHUB_TOKEN` không có quyền comment vào Issues/PRs.

## Solutions

### Solution 1: Enable Workflow Permissions (RECOMMENDED) ✅

**Cách 1: Repository Settings** (Áp dụng cho toàn repo)

1. Vào repository trên GitHub
2. Click **Settings** (tab bên phải)
3. Sidebar bên trái: **Actions** → **General**
4. Scroll xuống **Workflow permissions**
5. Chọn: **Read and write permissions** ✅
6. Check: **Allow GitHub Actions to create and approve pull requests** ✅
7. Click **Save**

**Cách 2: Organization Settings** (Nếu repo thuộc organization)

1. Organization Settings → Actions → General
2. Workflow permissions → Read and write permissions
3. Save

### Solution 2: Use Personal Access Token (Alternative)

Nếu không muốn enable write permissions cho GITHUB_TOKEN:

1. Tạo Personal Access Token:
   - GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token (classic)
   - Scopes: `repo`, `workflow`
   - Copy token

2. Add as Secret:
   - Repository → Settings → Secrets → New repository secret
   - Name: `PAT_TOKEN`
   - Value: [your token]

3. Update workflows:
   ```yaml
   - uses: actions/github-script@v7
     with:
       github-token: ${{ secrets.PAT_TOKEN }}  # Instead of secrets.GITHUB_TOKEN
   ```

### Solution 3: Remove PR Comments (Simplest)

Nếu không cần PR comments, comment out các steps:

```yaml
# - name: Comment PR with results
#   if: github.event_name == 'pull_request'
#   uses: actions/github-script@v7
#   ...
```

## What We Fixed in Code

### 1. Added explicit permissions to jobs:

```yaml
jobs:
  security-scan:
    permissions:
      contents: read
      security-events: write
      issues: write          # ← Added
      pull-requests: write   # ← Added
```

### 2. Added error handling:

```yaml
- name: Comment PR with results
  continue-on-error: true  # ← Won't fail workflow if comment fails
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
  script: |
    try {
      await github.rest.issues.createComment({...});
    } catch (error) {
      console.log('Could not create comment:', error.message);
    }
```

### 3. Made github-token explicit:

```yaml
with:
  github-token: ${{ secrets.GITHUB_TOKEN }}  # ← Explicit token
```

## Verification

After applying Solution 1, test with:

```bash
# Create a test PR
git checkout -b test/workflow-permissions
echo "test" > test.txt
git add test.txt
git commit -m "test: Verify workflow permissions"
git push origin test/workflow-permissions

# Create PR on GitHub
# Check Actions tab - should see PR comments now!
```

## Current Status

✅ **Fixed in code:**
- Added `issues: write` and `pull-requests: write` permissions
- Added error handling with `continue-on-error: true`
- Added try-catch blocks for API calls
- Made `github-token` explicit in all script actions

⚠️ **Required action:**
- Enable "Read and write permissions" in repository settings (Solution 1)
- OR use PAT token (Solution 2)
- OR disable PR comments (Solution 3)

## Test Checklist

- [ ] Repository settings updated (Settings → Actions → Workflow permissions)
- [ ] "Read and write permissions" enabled
- [ ] "Allow GitHub Actions to create and approve pull requests" checked
- [ ] Test PR created
- [ ] Workflow runs successfully
- [ ] PR comment appears
- [ ] No 403 errors in logs

## Alternative: Minimal Permissions Setup

Nếu bạn muốn giữ "Read repository contents and packages permissions" nhưng vẫn cho phép PR comments, có thể dùng:

```yaml
permissions:
  contents: read
  pull-requests: write  # Only what's needed
  issues: write         # Only what's needed
```

Và trong Settings, keep "Read repository contents" nhưng manually grant `issues` và `pull-requests` permissions qua fine-grained tokens.

---

**Recommended:** Dùng Solution 1 (Enable workflow permissions) - đơn giản nhất và standard practice cho CI/CD workflows.

