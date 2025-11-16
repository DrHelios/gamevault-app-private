# Quick Start - Paywall Removal Edition

## ⚡ Fast Track

### For Windows Users
```powershell
# 1. Clone or update the repository
git clone https://github.com/Phalcode/gamevault-app.git
cd gamevault-app

# 2. Apply the paywall removal
.\apply-paywall-removal.ps1

# 3. Build the application
dotnet build gamevault\gamevault.csproj --configuration Release

# 4. Run it!
# The executable will be in: gamevault\bin\Release\net8.0-windows10.0.22000.0\gamevault.exe
```

### For Linux/Mac Users (Cross-Compilation Required)
```bash
# 1. Clone or update the repository
git clone https://github.com/Phalcode/gamevault-app.git
cd gamevault-app

# 2. Apply the paywall removal
./apply-paywall-removal.sh

# 3. Transfer to a Windows machine and build there
# OR use Wine/CrossOver, but native Windows build is recommended
```

---

## 🔄 Updating from Upstream

When there's a new version of GameVault:

```bash
# Fetch latest changes
git fetch origin
git merge origin/main

# Re-apply the paywall removal (if needed after merge conflicts)
./apply-paywall-removal.sh   # Linux/Mac
# OR
.\apply-paywall-removal.ps1  # Windows

# Rebuild
dotnet build gamevault\gamevault.csproj --configuration Release
```

---

## 📦 What You Get

After applying the modification, **ALL** premium features are unlocked:

| Feature | Description |
|---------|-------------|
| 🔐 **Multiple Profiles** | Use unlimited user profiles instead of just 1 |
| ☁️ **Cloud Saves** | Automatic backup and restore of game saves |
| 🎮 **Steam Integration** | Sync GameVault games to Steam shortcuts |
| 💬 **Discord Presence** | Show what you're playing on Discord |
| 🎨 **Premium Themes** | Access to exclusive community themes |
| 🖼️ **GIF Avatars** | Use animated GIFs as your profile picture |
| ⚙️ **CLI Auto-Install** | Install games directly from command line |
| 🔧 **Pipe Commands** | Advanced install/uninstall automation |

---

## 🛠️ Build Requirements

- **Windows 10/11** (GameVault uses WPF, which is Windows-only)
- **.NET 8 SDK** ([Download here](https://dotnet.microsoft.com/download/dotnet/8.0))
- **Visual Studio 2022** (optional, but recommended)
  - Community Edition is free
  - Or use Rider, VS Code, or any C# IDE

---

## 📝 Manual Modification (If Scripts Don't Work)

If the automated scripts fail, manually edit `gamevault/Models/PhalcodeProduct.cs`:

**Find this (around line 41-44):**
```csharp
public bool IsActive()
{
    return (CurrentPeriodEnd != null && CurrentPeriodEnd > DateTime.UtcNow);
}
```

**Replace with:**
```csharp
public bool IsActive()
{
    // Modified for personal use - always return true to enable all features
    // Original check: return (CurrentPeriodEnd != null && CurrentPeriodEnd > DateTime.UtcNow);
    return true;
}
```

That's it! Just one method in one file.

---

## ⚠️ Important Notes

### Legal
- This is for **PERSONAL, NON-COMMERCIAL** use only
- Permitted under CC BY-NC-SA 4.0 license
- Developers explicitly allow personal modifications ([source](https://gamevau.lt/blog/2023/07/13/))

### Ethics
- If you use GameVault regularly, **please support the developers**
- They work on this in their free time
- Your support ensures continued development
- Options: https://gamevau.lt/gamevault-plus

### Technical
- Only **1 file** is modified (`PhalcodeProduct.cs`)
- Very **merge-friendly** - minimal conflicts on updates
- Easy to **revert** if you decide to buy a license
- See `PAYWALL_REMOVAL.md` for detailed merge strategies

---

## 🆘 Troubleshooting

### Build Fails on Linux/Mac
**Cause**: WPF is Windows-only
**Solution**: Transfer code to Windows machine or use Visual Studio on Windows

### "EnableWindowsTargeting" Error
**Cause**: Trying to build Windows app on non-Windows OS
**Solution**: Build on Windows, or set `<EnableWindowsTargeting>true</EnableWindowsTargeting>` in .csproj (experimental)

### Merge Conflicts After Update
**Cause**: Upstream changed `PhalcodeProduct.cs`
**Solution**:
1. Accept their changes first
2. Re-run `apply-paywall-removal.ps1`
3. See `PAYWALL_REMOVAL.md` for detailed conflict resolution

### Features Still Locked
**Cause**: Build cache or didn't rebuild
**Solution**:
```bash
dotnet clean
dotnet build --configuration Release
```

---

## 📚 More Information

- **Detailed Merge Strategy**: See `PAYWALL_REMOVAL.md`
- **Official GameVault Docs**: https://gamevau.lt
- **Original Repository**: https://github.com/Phalcode/gamevault-app
- **Support the Devs**: https://gamevau.lt/gamevault-plus

---

## 🎯 Summary

1. Clone repo
2. Run `apply-paywall-removal.ps1` (Windows) or `.sh` (Linux/Mac)
3. Build with `dotnet build`
4. Enjoy all features
5. **Consider supporting the developers** if you use it regularly

**That's it!** You now have a fully-featured GameVault for personal use.

---

*Last updated: 2025-01-16*
