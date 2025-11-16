# GitHub Actions Build Guide

## 🚀 Build GameVault Automatically (No Windows Required!)

GitHub Actions will build GameVault for you **in the cloud, for free**.

---

## ⚡ Quick Start (5 minutes)

### Step 1: Fork or Push to GitHub

**Option A: Fork the original repo**
```bash
# On GitHub.com:
# 1. Go to https://github.com/Phalcode/gamevault-app
# 2. Click "Fork" button
# 3. Clone YOUR fork:
git clone https://github.com/YOUR-USERNAME/gamevault-app.git
cd gamevault-app
```

**Option B: Push to your own repo**
```bash
cd /home/helios/Projects/gamevault-app

# Create a new repo on GitHub first, then:
git remote add myfork https://github.com/YOUR-USERNAME/gamevault-app.git
git push myfork master
```

### Step 2: Add Modified Files

The workflow file is already created at `.github/workflows/build-windows.yml`

```bash
git add .github/workflows/build-windows.yml
git add gamevault/Models/PhalcodeProduct.cs
git add apply-paywall-removal.ps1
git add PAYWALL_REMOVAL.md
git add QUICK_START.md
git commit -m "Add paywall removal for personal use"
git push
```

### Step 3: Watch the Build

1. Go to your GitHub repo
2. Click the **"Actions"** tab
3. You'll see the workflow running
4. Wait ~5 minutes for completion

### Step 4: Download the Build

1. Click on the completed workflow run
2. Scroll down to **"Artifacts"**
3. Download **"gamevault-windows-no-paywall"**
4. Extract the ZIP file
5. Run `gamevault.exe` on Windows!

---

## 🎯 Manual Trigger

You can also trigger builds manually without pushing code:

1. Go to **Actions** tab
2. Click **"Build GameVault (Paywall Removed)"** workflow
3. Click **"Run workflow"** button
4. Select branch (usually `main` or `master`)
5. Click **"Run workflow"**

---

## 📦 What You Get

After the build completes, you'll have **2 artifacts**:

### 1. `gamevault-windows-no-paywall.zip`
- Complete build package
- Ready to run on Windows
- Includes documentation
- Includes `BUILD_INFO.txt` with build details

**Contents:**
```
GameVault-custom-build-YYYY-MM-DD-HHMMSS/
├── gamevault.exe              ← Main executable
├── *.dll                       ← Dependencies
├── BUILD_INFO.txt             ← Build metadata
├── PAYWALL_REMOVAL.md         ← Documentation
├── QUICK_START.md             ← Quick start guide
└── README.md                  ← Original README
```

### 2. `gamevault-windows-build-files`
- Raw build output
- All DLLs and dependencies
- No documentation
- Smaller download

---

## ⚙️ Workflow Details

### What the Workflow Does

1. **Checks out your code** from GitHub
2. **Installs .NET 8 SDK** on a Windows runner
3. **Applies paywall removal** via PowerShell script
4. **Restores NuGet packages**
5. **Builds the Release configuration**
6. **Packages everything** into a ZIP file
7. **Uploads artifacts** for download

### Workflow File Location

`.github/workflows/build-windows.yml`

### Triggers

The workflow runs automatically on:
- **Push to `main` or `master` branch**
- **Pull requests to `main` or `master`**
- **Manual trigger** (workflow_dispatch)

---

## 🔧 Customization

### Change Build Configuration

Edit `.github/workflows/build-windows.yml`:

```yaml
# Change from Release to Debug
- name: Build
  run: dotnet build gamevault/gamevault.csproj --configuration Debug --no-restore
```

### Change Artifact Retention

```yaml
- name: Upload build artifact
  uses: actions/upload-artifact@v4
  with:
    name: gamevault-windows-no-paywall
    path: GameVault-NoPaywall-*.zip
    retention-days: 90  # ← Change this (max 90 days for free accounts)
```

### Add Automatic Releases

Add this to the end of the workflow to create GitHub Releases:

```yaml
- name: Create Release
  if: startsWith(github.ref, 'refs/tags/')
  uses: softprops/action-gh-release@v1
  with:
    files: GameVault-NoPaywall-*.zip
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Then tag your commits:
```bash
git tag v1.0.0-no-paywall
git push origin v1.0.0-no-paywall
```

---

## 📊 Build Status Badge

Add to your README.md to show build status:

```markdown
![Build Status](https://github.com/YOUR-USERNAME/gamevault-app/workflows/Build%20GameVault%20(Paywall%20Removed)/badge.svg)
```

---

## 💰 Costs

### Free Tier (Public Repos)
- ✅ **Unlimited** build minutes
- ✅ Free forever
- ✅ Windows runners included

### Free Tier (Private Repos)
- ✅ **2,000 minutes/month** (Windows counts 2x, so 1,000 effective minutes)
- ✅ Each build takes ~5 minutes = 200 builds/month
- ✅ More than enough for personal use

### If You Exceed Free Tier
- **$0.008 per minute** for Windows runners
- A single build costs ~$0.08
- Still very cheap!

---

## 🐛 Troubleshooting

### Build Fails with "workflow file not found"

**Cause:** File is in wrong location or branch

**Fix:**
```bash
# Make sure file is in correct location
ls .github/workflows/build-windows.yml

# Make sure it's pushed
git add .github/workflows/build-windows.yml
git commit -m "Add workflow"
git push
```

### Build Fails with "script not found"

**Cause:** `apply-paywall-removal.ps1` is missing

**Fix:**
```bash
# Make sure the script is committed
git add apply-paywall-removal.ps1
git commit -m "Add paywall removal script"
git push
```

### Can't Download Artifacts

**Cause:** Artifacts expire after retention period (default 90 days)

**Fix:** Trigger a new build (see "Manual Trigger" above)

### Build Succeeds but App Crashes on Windows

**Cause:** Missing dependencies or .NET runtime

**Fix:**
1. Install .NET 8 Desktop Runtime on Windows
2. Download from: https://dotnet.microsoft.com/download/dotnet/8.0
3. Choose "Desktop Runtime"

---

## 🔄 Keeping Updated

### Merge Upstream Changes

```bash
# Add upstream remote (if you forked)
git remote add upstream https://github.com/Phalcode/gamevault-app.git

# Fetch latest changes
git fetch upstream

# Merge into your branch
git merge upstream/main

# Re-apply paywall removal if needed
.\apply-paywall-removal.ps1

# Commit and push
git add gamevault/Models/PhalcodeProduct.cs
git commit -m "Merge upstream + re-apply paywall removal"
git push

# GitHub Actions will automatically build the new version
```

---

## 📈 Advanced: Build Matrix

Build for multiple configurations at once:

```yaml
strategy:
  matrix:
    configuration: [Debug, Release]
    platform: [x64, AnyCPU]

steps:
  - name: Build
    run: dotnet build gamevault/gamevault.csproj --configuration ${{ matrix.configuration }} -p:Platform=${{ matrix.platform }}
```

---

## 🎓 Learn More

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Workflow Syntax](https://docs.github.com/actions/reference/workflow-syntax-for-github-actions)
- [.NET Build Tasks](https://docs.microsoft.com/dotnet/core/tools/dotnet-build)

---

## ✅ Checklist

Before pushing to GitHub:

- [ ] Modified `PhalcodeProduct.cs` (paywall removal)
- [ ] Added `apply-paywall-removal.ps1`
- [ ] Added `.github/workflows/build-windows.yml`
- [ ] Committed all documentation files
- [ ] Pushed to GitHub
- [ ] Checked Actions tab for build status
- [ ] Downloaded and tested artifact

---

## 🎉 Success!

Once the build completes:

1. Download the ZIP from Artifacts
2. Extract on Windows
3. Run `gamevault.exe`
4. Enjoy all premium features!

**Remember:** This is for personal use only. Support the developers if you use it regularly: https://gamevau.lt/gamevault-plus

---

*Note: GitHub Actions uses shared runners. If you have a specific Windows version requirement, you may need to use self-hosted runners.*
