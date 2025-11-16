# Build Options for GameVault on Linux

## ❌ TL;DR: Native Linux Build is Not Possible

**GameVault uses WPF (Windows Presentation Foundation), which requires Windows.**

The SDK error you'll get on Linux:
```
error MSB4019: le projet importé ".../Microsoft.NET.Sdk.WindowsDesktop.targets" est introuvable
```

This is because:
- **WPF** is a Windows-only UI framework
- **Windows Forms** is Windows-only
- These depend on native Windows libraries that don't exist on Linux

---

## ✅ Available Options (Ranked by Ease)

### Option 1: **Use a Windows Machine** ⭐ RECOMMENDED

**Pros:**
- Native compilation
- Fastest build times
- No compatibility issues
- Can test the app immediately

**Steps:**
```powershell
# On Windows
cd /home/helios/Projects/gamevault-app  # Or wherever you copied it
.\apply-paywall-removal.ps1
dotnet build gamevault\gamevault.csproj --configuration Release

# Output: gamevault\bin\Release\net8.0-windows10.0.22000.0\gamevault.exe
```

**Requirements:**
- Windows 10/11
- .NET 8 SDK: https://dotnet.microsoft.com/download/dotnet/8.0

---

### Option 2: **Windows VM on Linux** ⭐ GOOD OPTION

Use virtualization to run Windows on your Linux machine.

**Tools:**
- **VirtualBox** (Free, open-source)
- **VMware Workstation Player** (Free for personal use)
- **QEMU/KVM** with virt-manager (Linux native, best performance)
- **Parallels** (macOS)

**Steps:**
1. Install VM software
2. Create a Windows 10/11 VM
3. Install .NET 8 SDK in the VM
4. Share the project folder with the VM
5. Build inside the VM

**Pros:**
- Free (with VirtualBox or KVM)
- Keep working on Linux
- Can reuse for other Windows-only apps

**Cons:**
- Requires ~20GB disk space for Windows
- Slower than native
- Needs virtualization support (Intel VT-x / AMD-V)

**Recommended VM Setup:**
- RAM: 4GB minimum, 8GB recommended
- Disk: 40GB
- CPU: 2 cores minimum

---

### Option 3: **GitHub Actions / GitLab CI** ⭐ AUTOMATED

Use free CI/CD to build automatically on every commit.

**GitHub Actions Example** (`.github/workflows/build.yml`):
```yaml
name: Build GameVault

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  build:
    runs-on: windows-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: 8.0.x

    - name: Apply Paywall Removal
      run: .\apply-paywall-removal.ps1
      shell: pwsh

    - name: Restore dependencies
      run: dotnet restore gamevault/gamevault.csproj

    - name: Build
      run: dotnet build gamevault/gamevault.csproj --configuration Release --no-restore

    - name: Upload Artifact
      uses: actions/upload-artifact@v3
      with:
        name: gamevault-windows
        path: gamevault/bin/Release/net8.0-windows10.0.22000.0/
```

**Pros:**
- Completely free
- Automated builds
- No Windows machine needed
- Download built executables from GitHub

**Cons:**
- Requires pushing to GitHub/GitLab
- Build artifacts expire after 90 days
- Public repo required for unlimited minutes (or use private with limits)

**Setup Time:** 5-10 minutes

---

### Option 4: **Remote Windows Build Server**

Use a remote Windows machine or cloud service.

**Options:**
- **Azure DevOps Pipelines** (Free tier available)
- **AppVeyor** (Free for open-source)
- **Friend's Windows PC** (SSH or Remote Desktop)

**Example with SSH:**
```bash
# From Linux, rsync code to Windows machine
rsync -avz /home/helios/Projects/gamevault-app/ user@windows-pc:/path/to/gamevault-app/

# SSH into Windows machine
ssh user@windows-pc

# Build remotely
cd /path/to/gamevault-app
.\apply-paywall-removal.ps1
dotnet build gamevault\gamevault.csproj --configuration Release

# Copy back the executable
# From Linux:
scp user@windows-pc:/path/to/gamevault-app/gamevault/bin/Release/net8.0-windows10.0.22000.0/gamevault.exe ~/
```

**Pros:**
- No local Windows needed
- Can be automated

**Cons:**
- Requires access to a Windows machine
- Network dependency
- More complex setup

---

### Option 5: **Wine + Mono (NOT RECOMMENDED)**

⚠️ **This rarely works for WPF apps and is not recommended.**

Wine doesn't fully support WPF. Even if it builds, the app won't run properly.

**Why this fails:**
- Wine's WPF support is incomplete
- Missing native Windows APIs
- Visual glitches and crashes
- Not worth the effort

**Only try this if:**
- You're curious and have time to waste
- You understand it probably won't work
- You're okay with spending hours troubleshooting

---

## 🎯 Recommended Solution for Your Situation

Based on your Linux environment, here are the best options:

### If you have ANY Windows machine available:
→ **Use Option 1** (native Windows build)

### If you DON'T have Windows but have 40GB disk space:
→ **Use Option 2** (VirtualBox VM)
- Download Windows 10 ISO from Microsoft
- Install VirtualBox: `sudo apt install virtualbox`
- Create VM, install .NET 8 SDK, build

### If you want automated builds:
→ **Use Option 3** (GitHub Actions)
- Fork the repo to your GitHub
- Add the workflow file
- Push your changes
- Download built artifacts

---

## 📦 Quick VM Setup Guide (VirtualBox)

```bash
# Install VirtualBox
sudo apt install virtualbox

# Download Windows 10/11 ISO from Microsoft
# (Free for evaluation/development)

# Create VM via GUI or:
VBoxManage createvm --name "Windows10" --ostype Windows10_64 --register
VBoxManage modifyvm "Windows10" --memory 8192 --cpus 2
VBoxManage createhd --filename ~/VirtualBox\ VMs/Windows10/Windows10.vdi --size 40960
VBoxManage storagectl "Windows10" --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach "Windows10" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ~/VirtualBox\ VMs/Windows10/Windows10.vdi
VBoxManage storageattach "Windows10" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium ~/Downloads/Win10_*.iso

# Start VM
VBoxManage startvm "Windows10"

# After Windows is installed:
# 1. Install VirtualBox Guest Additions (for shared folders)
# 2. Install .NET 8 SDK from https://dotnet.microsoft.com/download
# 3. Share your project folder: Devices → Shared Folders
# 4. Build in the VM
```

---

## 🚀 Fastest Path to Working Build

**5-Minute Solution (if you have GitHub account):**

1. Fork https://github.com/Phalcode/gamevault-app to your GitHub
2. Create `.github/workflows/build.yml` with the GitHub Actions example above
3. Push your paywall removal changes
4. Wait 5 minutes for build to complete
5. Download from Actions tab → Latest run → Artifacts

**30-Minute Solution (if you have Windows machine):**

1. Transfer `/home/helios/Projects/gamevault-app/` to Windows
2. Install .NET 8 SDK
3. Run `apply-paywall-removal.ps1`
4. Run `dotnet build gamevault\gamevault.csproj --configuration Release`
5. Done!

**2-Hour Solution (VM on Linux):**

1. Install VirtualBox
2. Download Windows 10 ISO
3. Create VM (8GB RAM, 40GB disk)
4. Install Windows + .NET 8 SDK
5. Build the app

---

## ⚠️ Important Notes

### Why Not Cross-Compile?

.NET does support cross-compilation for **some** platforms, but:
- WPF uses native Windows DLLs (`PresentationFramework.dll`, etc.)
- These are compiled C++ code, not .NET
- They literally cannot run on Linux
- It's not a configuration issue—it's a fundamental limitation

### What About Avalonia UI?

Avalonia is a cross-platform alternative to WPF that CAN run on Linux. However:
- GameVault is written in WPF, not Avalonia
- Porting would require rewriting the entire UI
- That's a massive undertaking (weeks/months of work)
- Not practical for this use case

---

## 📊 Comparison Table

| Option | Cost | Setup Time | Build Time | Complexity | Recurring Work |
|--------|------|------------|------------|------------|----------------|
| Windows Machine | Free/Owned | 5 min | 2 min | ⭐ Easy | None |
| VirtualBox VM | Free | 2 hours | 5 min | ⭐⭐ Medium | VM maintenance |
| GitHub Actions | Free | 10 min | 5 min | ⭐⭐ Medium | None (automated) |
| Remote Windows | Varies | 30 min | 3 min | ⭐⭐⭐ Hard | Network setup |
| Wine + Mono | Free | 5 hours | Won't work | ⭐⭐⭐⭐⭐ Expert | Constant debugging |

---

## 🎯 My Recommendation

**For you specifically:**

1. **If you have access to ANY Windows machine** (friend, work, etc.):
   - Copy the folder there
   - Build it once
   - You're done in 10 minutes

2. **If you don't have Windows but this is a one-time need:**
   - Use **GitHub Actions** (easiest, no local setup)

3. **If you'll be updating frequently:**
   - Install **VirtualBox + Windows VM** (one-time 2-hour setup, then easy forever)

---

## 📞 Need Help?

Check the official docs:
- .NET on Windows: https://docs.microsoft.com/dotnet/core/install/windows
- VirtualBox: https://www.virtualbox.org/manual/
- GitHub Actions: https://docs.github.com/actions

---

*Note: All modifications assume you've already applied the paywall removal as documented in `PAYWALL_REMOVAL.md`*
