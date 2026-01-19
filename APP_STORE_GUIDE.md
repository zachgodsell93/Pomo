# Publishing Pomo to the Mac App Store

This guide walks you through the process of publishing Pomo to the Mac App Store.

## Prerequisites

1. **Apple Developer Account** ($99/year)
   - Sign up at [developer.apple.com](https://developer.apple.com)
   - Enroll in the Apple Developer Program

2. **Xcode** (latest version recommended)
   - Download from the Mac App Store

3. **App-Specific Assets**
   - App icon (1024x1024 PNG, no transparency)
   - Screenshots for Mac App Store (at least one)
   - App description, keywords, and privacy policy URL

---

## Step 1: Create an Xcode Project

Since Pomo uses Swift Package Manager, you'll need to create an Xcode project:

1. Open Xcode → File → New → Project
2. Select **macOS → App**
3. Configure:
   - Product Name: `Pomo`
   - Team: Your Apple Developer team
   - Organization Identifier: `com.yourname` (e.g., `com.zachgodsell`)
   - Bundle Identifier: `com.yourname.pomo`
   - Interface: SwiftUI
   - Language: Swift

4. Copy all source files from this project into the Xcode project:
   - `App/AppDelegate.swift`
   - `Model/SettingsManager.swift`
   - `Model/SessionHistoryManager.swift`
   - `Model/TimerManager.swift`
   - `Views/MainView.swift`
   - `Views/SettingsView.swift`
   - `Views/StatsView.swift`
   - `Utils/Theme.swift`
   - `main.swift`

5. Delete the auto-generated `PomoApp.swift` (we use `main.swift` with AppDelegate)

---

## Step 2: Configure App Settings

### Deployment Target
Set the minimum deployment target to **macOS 13.0** (Ventura) or later. This is required because the app uses Swift Charts for statistics visualization.

In Xcode: Select project → General → Minimum Deployments → macOS 13.0

### Info.plist
Add/update these keys:

```xml
<key>LSUIElement</key>
<true/>  <!-- Makes it a menu bar app (no dock icon) -->

<key>NSHumanReadableCopyright</key>
<string>Copyright © 2024 Your Name. All rights reserved.</string>
```

### Signing & Capabilities (in Xcode)

1. Select project → Signing & Capabilities
2. Enable **Automatically manage signing**
3. Select your Team
4. Add capability: **App Sandbox** (required for App Store)

### App Sandbox Entitlements

Create `Pomo.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
</dict>
</plist>
```

Pomo is simple and doesn't need extra entitlements. If you add features later:
- Network access: `com.apple.security.network.client`
- File access: `com.apple.security.files.user-selected.read-write`

---

## Step 3: Create App Icon

1. Create a 1024x1024 PNG icon (no transparency, no rounded corners - Apple adds them)
2. Use an icon generator tool to create the `.iconset`:
   - 16x16, 16x16@2x
   - 32x32, 32x32@2x
   - 128x128, 128x128@2x
   - 256x256, 256x256@2x
   - 512x512, 512x512@2x

3. In Xcode, open `Assets.xcassets` → AppIcon and drag in your icons

---

## Step 4: App Store Connect Setup

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - Platform: macOS
   - Name: Pomo (or your preferred name)
   - Primary Language: English
   - Bundle ID: Select from dropdown (must match Xcode)
   - SKU: `pomo-timer` (unique identifier, not shown to users)

### App Information
- Category: **Productivity**
- Content Rights: Confirm you own or have rights to all content
- Age Rating: Complete the questionnaire (Pomo should be 4+)

### Pricing and Availability
- Price: Free (or select a price tier)
- Availability: Select countries

### App Privacy
Since Pomo stores data locally only:
- Data Collection: **None**
- You still need a Privacy Policy URL (can be a simple page on your website or GitHub)

Example minimal privacy policy:
> Pomo does not collect, store, or transmit any personal data. All settings are stored locally on your device.

---

## Step 5: Prepare Screenshots

Required: At least one screenshot

Recommended sizes for Mac:
- 1280 x 800 pixels
- 1440 x 900 pixels
- 2560 x 1600 pixels
- 2880 x 1800 pixels

Tips:
- Show the app in both light and dark mode
- Use a clean desktop background
- Consider using a tool like CleanShot X or Screenshot Path

---

## Step 6: Build and Archive

1. In Xcode, select **Product → Scheme → Edit Scheme**
2. Set Build Configuration to **Release**
3. Select **Any Mac (Apple Silicon, Intel)** as destination
4. **Product → Archive**
5. When complete, the Organizer window opens

---

## Step 7: Upload to App Store Connect

1. In Organizer, select your archive
2. Click **Distribute App**
3. Select **App Store Connect**
4. Choose **Upload**
5. Follow prompts (keep defaults for most options)
6. Wait for upload and processing (5-15 minutes)

---

## Step 8: Submit for Review

1. In App Store Connect, go to your app
2. Select the build you uploaded
3. Fill in **What's New in This Version**
4. Add screenshots and app preview (optional)
5. Write your app description:

```
Pomo is a beautiful, minimal Pomodoro timer that floats on your desktop.

Features:
• Clean, distraction-free interface
• Customizable focus and break durations
• Visual progress tracking with session dots
• Statistics dashboard with charts and streaks
• Track your focus history over time
• Dark mode support
• Menu bar integration
• Always-on-top floating window

Stay focused and productive with Pomo.
```

6. Add keywords (100 characters max):
   `pomodoro,timer,focus,productivity,time management,study,work,break,statistics,tracker`

7. Click **Submit for Review**

---

## Step 9: App Review

- Review typically takes 24-48 hours (can be faster or longer)
- Apple may request changes or clarification
- Common rejection reasons:
  - Crashes or bugs
  - Incomplete features
  - Misleading description
  - Privacy policy issues

---

## Post-Launch

### Updates
1. Increment version number in Xcode (e.g., 1.0.1)
2. Increment build number
3. Archive and upload
4. Submit new version for review

### Responding to Reviews
- Monitor ratings and reviews in App Store Connect
- Respond professionally to feedback

---

## Alternative: Direct Distribution

If you don't want to use the App Store, you can distribute directly:

1. **Developer ID Signed App**
   - Archive → Distribute App → Developer ID
   - Users can download from your website
   - Requires notarization

2. **Notarization**
   ```bash
   xcrun notarytool submit Pomo.zip --apple-id your@email.com --team-id YOURTEAMID --password app-specific-password
   ```

3. **Create DMG for distribution**
   ```bash
   hdiutil create -volname "Pomo" -srcfolder Pomo.app -ov -format UDZO Pomo.dmg
   ```

---

## Checklist

- [ ] Apple Developer Account active
- [ ] Xcode project created with correct bundle ID
- [ ] App Sandbox enabled
- [ ] App icon added (all sizes)
- [ ] Screenshots prepared
- [ ] Privacy policy URL ready
- [ ] App Store Connect listing created
- [ ] App description and keywords written
- [ ] Archive built successfully
- [ ] Uploaded to App Store Connect
- [ ] Submitted for review

---

## Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines - macOS](https://developer.apple.com/design/human-interface-guidelines/macos)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Notarizing macOS Software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
