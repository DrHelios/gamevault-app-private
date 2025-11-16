#!/bin/bash

# GameVault Paywall Removal Script
# For personal, non-commercial use only
# See PAYWALL_REMOVAL.md for details

set -e

echo "=================================="
echo "GameVault Paywall Removal Script"
echo "=================================="
echo ""

# Check if we're in the right directory
if [ ! -f "gamevault/Models/PhalcodeProduct.cs" ]; then
    echo "❌ Error: Please run this script from the gamevault-app root directory"
    exit 1
fi

echo "📋 Applying paywall removal patch..."

# Try to apply the patch
if git apply paywall-removal.patch 2>/dev/null; then
    echo "✅ Patch applied successfully!"
else
    echo "⚠️  Patch failed to apply cleanly. Trying manual modification..."

    # Manual modification as fallback
    sed -i '/public bool IsActive()/,/^[[:space:]]*}$/ {
        /return (CurrentPeriodEnd != null && CurrentPeriodEnd > DateTime.UtcNow);/c\
            // Modified for personal use - always return true to enable all features\
            // Original check: return (CurrentPeriodEnd != null && CurrentPeriodEnd > DateTime.UtcNow);\
            return true;
    }' gamevault/Models/PhalcodeProduct.cs

    if [ $? -eq 0 ]; then
        echo "✅ Manual modification completed!"
    else
        echo "❌ Failed to apply modifications. Please check PAYWALL_REMOVAL.md for manual instructions."
        exit 1
    fi
fi

echo ""
echo "✨ All premium features are now unlocked!"
echo ""
echo "Features enabled:"
echo "  ✅ Multiple User Profiles"
echo "  ✅ Cloud Saves"
echo "  ✅ Steam Shortcuts Sync"
echo "  ✅ Discord Rich Presence"
echo "  ✅ Premium Themes"
echo "  ✅ Animated GIF Avatars"
echo "  ✅ CLI Auto-Install"
echo "  ✅ Install/Uninstall Commands"
echo ""
echo "⚠️  Remember: This is for PERSONAL USE only."
echo "    If you find GameVault useful, please support the developers:"
echo "    https://gamevau.lt/gamevault-plus"
echo ""
echo "📖 For merge instructions, see: PAYWALL_REMOVAL.md"
echo ""
