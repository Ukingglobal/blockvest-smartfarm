# BlockVest SmartFarm APK Installation Guide

## 🎉 APK Successfully Built!

**APK Location:** `/mnt/persist/workspace/build/app/outputs/flutter-apk/app-release.apk`
**APK Size:** 56MB (58.1MB)
**Build Date:** July 2, 2025
**Version:** 1.0.0

## 📱 Installation Methods

### Method 1: ADB Installation (Recommended for Developers)

#### Prerequisites:
1. Enable Developer Options on your Android device:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options
   - Enable "USB Debugging"

2. Install ADB on your computer:
   ```bash
   # On Ubuntu/Debian:
   sudo apt install android-tools-adb
   
   # On macOS:
   brew install android-platform-tools
   
   # On Windows:
   # Download Android SDK Platform Tools from Google
   ```

#### Installation Steps:
1. Connect your Android device to your computer via USB
2. Copy the APK to your computer
3. Open terminal/command prompt
4. Navigate to the APK location
5. Install using ADB:
   ```bash
   adb install app-release.apk
   ```

### Method 2: Manual Sideloading

#### Prerequisites:
1. Enable "Unknown Sources" or "Install from Unknown Sources":
   - Android 8.0+: Settings > Apps & Notifications > Special App Access > Install Unknown Apps
   - Older Android: Settings > Security > Unknown Sources

#### Installation Steps:
1. Transfer the APK file to your Android device:
   - Via USB cable (copy to Downloads folder)
   - Via email attachment
   - Via cloud storage (Google Drive, Dropbox, etc.)
   - Via file sharing apps

2. On your Android device:
   - Open File Manager
   - Navigate to the APK location
   - Tap on `app-release.apk`
   - Tap "Install" when prompted
   - Wait for installation to complete
   - Tap "Open" to launch the app

## 🔧 Troubleshooting

### Common Issues:

1. **"App not installed" error:**
   - Ensure you have enough storage space (at least 200MB free)
   - Try uninstalling any previous version first
   - Check if "Install from Unknown Sources" is enabled

2. **"Parse error" or "Invalid APK":**
   - Re-download the APK file
   - Ensure the file wasn't corrupted during transfer
   - Check if your device architecture is supported (ARM64/ARMv7)

3. **Permission errors:**
   - Grant all requested permissions during installation
   - Check app permissions in Settings after installation

### Device Requirements:
- **Minimum Android Version:** 6.0 (API 23)
- **Target Android Version:** 14.0 (API 35)
- **Architecture:** ARM64-v8a, ARMv7a
- **RAM:** Minimum 2GB recommended
- **Storage:** 200MB free space

## 🚀 App Features Included

The APK includes all implemented features:

### ✅ Authentication & Security
- Biometric authentication (fingerprint/face unlock)
- Face scanning for KYC verification
- Secure local storage
- PIN/password fallback

### ✅ Dashboard
- Portfolio overview
- Investment tracking
- Real-time updates
- Performance metrics

### ✅ Staking System
- Multiple staking plans
- Reward calculations
- Staking history
- Position management

### ✅ Marketplace
- Project listings
- Investment opportunities
- Project details
- Risk assessments

### ✅ Blockchain Integration
- Supra blockchain connectivity
- Wallet functionality
- Transaction history
- Smart contract interactions

### ✅ UI/UX
- BlockVest design system
- Material Design 3
- Dark/light theme support
- Responsive layout

## 🧪 Testing Checklist

After installation, test these features:

1. **Launch App:** Verify app opens without crashes
2. **Authentication:** Test biometric/PIN login
3. **Navigation:** Check all bottom navigation tabs
4. **Dashboard:** Verify data displays correctly
5. **Staking:** Test staking plan selection
6. **Marketplace:** Browse investment projects
7. **Settings:** Check app settings and preferences

## 📞 Support

If you encounter any issues:

1. Check device compatibility
2. Ensure latest Android security updates
3. Try clearing app cache/data
4. Reinstall the app
5. Report bugs with device info and error logs

## 🔄 Updates

To update the app:
1. Uninstall the current version
2. Install the new APK file
3. Or use in-app update mechanism (if implemented)

---

**Note:** This is a development build. For production use, the APK should be signed with a release keystore and distributed through official channels.
