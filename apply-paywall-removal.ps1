# GameVault Paywall Removal Script (PowerShell)
# For personal, non-commercial use only
# See PAYWALL_REMOVAL.md for details

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "GameVault Paywall Removal Script" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "gamevault\Models\PhalcodeProduct.cs")) {
    Write-Host "❌ Error: Please run this script from the gamevault-app root directory" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Applying paywall removal patch..." -ForegroundColor Yellow

$filePath = "gamevault\Models\PhalcodeProduct.cs"
$content = Get-Content $filePath -Raw

# Check if already modified
if ($content -match "Modified for personal use") {
    Write-Host "✅ Paywall removal already applied!" -ForegroundColor Green
    exit 0
}

# Apply the modification
$pattern = '(?s)(public bool IsActive\(\)\s*\{\s*)(return \(CurrentPeriodEnd != null && CurrentPeriodEnd > DateTime\.UtcNow\);)(\s*\})'
$replacement = '$1// Modified for personal use - always return true to enable all features
            // Original check: return (CurrentPeriodEnd != null && CurrentPeriodEnd > DateTime.UtcNow);
            return true;$3'

if ($content -match $pattern) {
    $newContent = $content -replace $pattern, $replacement
    Set-Content -Path $filePath -Value $newContent -NoNewline
    Write-Host "✅ Modification completed successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to find the IsActive() method. File may have changed." -ForegroundColor Red
    Write-Host "    Please check PAYWALL_REMOVAL.md for manual instructions." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "✨ All premium features are now unlocked!" -ForegroundColor Green
Write-Host ""
Write-Host "Features enabled:" -ForegroundColor Cyan
Write-Host "  ✅ Multiple User Profiles" -ForegroundColor Green
Write-Host "  ✅ Cloud Saves" -ForegroundColor Green
Write-Host "  ✅ Steam Shortcuts Sync" -ForegroundColor Green
Write-Host "  ✅ Discord Rich Presence" -ForegroundColor Green
Write-Host "  ✅ Premium Themes" -ForegroundColor Green
Write-Host "  ✅ Animated GIF Avatars" -ForegroundColor Green
Write-Host "  ✅ CLI Auto-Install" -ForegroundColor Green
Write-Host "  ✅ Install/Uninstall Commands" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  Remember: This is for PERSONAL USE only." -ForegroundColor Yellow
Write-Host "    If you find GameVault useful, please support the developers:" -ForegroundColor Yellow
Write-Host "    https://gamevau.lt/gamevault-plus" -ForegroundColor Yellow
Write-Host ""
Write-Host "📖 For merge instructions, see: PAYWALL_REMOVAL.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔨 To build the application, run:" -ForegroundColor Cyan
Write-Host "    dotnet build gamevault\gamevault.csproj --configuration Release" -ForegroundColor White
Write-Host ""
