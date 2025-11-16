# Paywall Removal for Personal Use

## Legal Notice

This modification is made under the CC BY-NC-SA 4.0 license and the explicit permission from the GameVault developers who stated in their blog (https://gamevau.lt/blog/2023/07/13/):

> "we absolutely encourage you to copy, modify, and share our code for personal use"

**This is for PERSONAL, NON-COMMERCIAL use only.**

If you find GameVault useful, please consider supporting the developers: https://gamevau.lt/gamevault-plus

---

## Modification Strategy

To make future merges as simple as possible, we use a **minimal, centralized approach**:

### Single Point of Modification

**File**: `gamevault/Models/PhalcodeProduct.cs`
**Method**: `IsActive()`
**Line**: ~43

### Original Code
```csharp
public bool IsActive()
{
    return (CurrentPeriodEnd != null && CurrentPeriodEnd > DateTime.UtcNow);
}
```

### Modified Code
```csharp
public bool IsActive()
{
    // Modified for personal use - always return true to enable all features
    // Original check: return (CurrentPeriodEnd != null && CurrentPeriodEnd > DateTime.UtcNow);
    return true;
}
```

---

## Why This Approach?

1. **Single File Change**: Only one file is modified
2. **Single Method Change**: Only one method is modified
3. **Minimal Conflict Risk**: Future merges will only conflict if `IsActive()` itself is changed
4. **Easy to Revert**: Just uncomment the original line and remove the `return true;`
5. **No Infrastructure Changes**: No need to modify build files, configs, or multiple source files

---

## Features Unlocked

By making this change, all premium features become available:

- ✅ **Multiple User Profiles** (unlimited instead of 1)
- ✅ **Cloud Saves** (automatic backup/restore)
- ✅ **Steam Shortcuts Sync**
- ✅ **Discord Rich Presence**
- ✅ **Premium Themes**
- ✅ **Animated GIF Avatars**
- ✅ **Command-Line Auto-Install**
- ✅ **Install/Uninstall via Pipe Commands**

---

## How to Merge Upstream Updates

### 1. Fetch Latest Changes
```bash
git remote add upstream https://github.com/Phalcode/gamevault-app.git
git fetch upstream
git merge upstream/main
```

### 2. Handle Conflicts (if any)

If there's a conflict in `PhalcodeProduct.cs`, it will look like this:

```csharp
<<<<<<< HEAD
public bool IsActive()
{
    // Modified for personal use - always return true to enable all features
    // Original check: return (CurrentPeriodEnd != null && CurrentPeriodEnd > DateTime.UtcNow);
    return true;
}
=======
public bool IsActive()
{
    // Some new upstream logic
    return [new upstream logic];
}
>>>>>>> upstream/main
```

**Resolution**: Simply replace the entire method with:
```csharp
public bool IsActive()
{
    // Modified for personal use - always return true to enable all features
    // Original: [paste the new upstream logic here as a comment]
    return true;
}
```

### 3. Rebuild
```bash
dotnet build gamevault/gamevault.csproj --configuration Release
```

---

## Alternative: Using Git Patches

You can also maintain this as a Git patch:

### Create the patch
```bash
git diff > paywall-removal.patch
```

### Apply after merging upstream
```bash
git merge upstream/main
git apply paywall-removal.patch
```

---

## Reverting to Original

To restore the paywall (e.g., to support the developers after trying it):

1. Open `gamevault/Models/PhalcodeProduct.cs`
2. Replace the `IsActive()` method with:
```csharp
public bool IsActive()
{
    return (CurrentPeriodEnd != null && CurrentPeriodEnd > DateTime.UtcNow);
}
```
3. Rebuild the application

---

## Building the Application

### Prerequisites
- Windows 10/11 (WPF is Windows-only)
- .NET 8 SDK
- Visual Studio 2022 or Rider (recommended)

### Build Steps
```bash
# Restore dependencies
dotnet restore gamevault/gamevault.csproj

# Build
dotnet build gamevault/gamevault.csproj --configuration Release

# Output will be in: gamevault/bin/Release/net8.0-windows10.0.22000.0/
```

### Using Visual Studio
1. Open `gamevault.sln`
2. Select "Release" configuration
3. Build → Build Solution (Ctrl+Shift+B)

---

## Support the Developers

If you use this modification and find GameVault valuable, please consider:

- 💳 **Buying GameVault+**: https://gamevau.lt/gamevault-plus
- ☕ **Donating**: Ko-Fi, Liberapay, GitHub Sponsors, or PayPal
- ⭐ **Starring the repo**: https://github.com/Phalcode/gamevault-app
- 🗣️ **Spreading the word**: Tell others about GameVault

The developers work on this in their free time. Supporting them ensures continued development!

---

## Changelog

### 2025-01-16
- Initial modification: Modified `PhalcodeProduct.IsActive()` to return `true`
- Created this documentation for merge strategy

---

## Questions?

If the upstream significantly changes the license validation system:
1. Search for all references to `License.IsActive()`
2. Verify they still use the centralized `IsActive()` method
3. If yes, no additional changes needed
4. If no, update this document with the new strategy

---

**Remember**: This is for personal use only. Respect the developers' work and the CC BY-NC-SA 4.0 license terms.
