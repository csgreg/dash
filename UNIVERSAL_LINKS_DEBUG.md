# Universal Links Debugging Guide

## Changes Made

Added comprehensive logging and dual Universal Link handlers for better iOS 18 compatibility.

## Debug Console Logs

When a Universal Link is opened, you should see this sequence:

```
🔗 AppDelegate/WindowGroup: Universal Link received: https://www.justdashapp.com/join/abc123
📍 DeepLinkHandler: Processing URL: https://www.justdashapp.com/join/abc123
📍 URL Host: www.justdashapp.com
📍 URL Path: /join/abc123
📍 Path components: ["/", "join", "abc123"]
✅ Successfully parsed listId: abc123
✅ Set activeDeepLink to .joinList(abc123)
🎯 ContentView: handleDeepLink called with: joinList("abc123")
📋 ContentView: Attempting to join list: abc123
✅ ContentView: User logged in, joining list...
📨 ContentView: Join result: [success/error message]
```

## AASA File Requirements for iOS 18

Your AASA file at `https://www.justdashapp.com/.well-known/apple-app-site-association` should be:

### ✅ Correct Format (iOS 13+)
```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["8VZSVBTHF7.com.csgergo.dash"],
        "components": [
          {
            "/": "/join/*",
            "comment": "Matches any list join link"
          }
        ]
      }
    ]
  }
}
```

### ⚠️ Alternative (Legacy but works)
```json
{
  "applinks": {
    "details": [
      {
        "appID": "8VZSVBTHF7.com.csgergo.dash",
        "paths": ["/join/*"]
      }
    ]
  }
}
```

**REMOVE** the `"apps": []` field - it's deprecated and can cause issues!

## Verification Steps

### 1. Test AASA File
```bash
# Check if it's accessible and returns JSON
curl -I https://www.justdashapp.com/.well-known/apple-app-site-association

# Should return:
# Content-Type: application/json (NOT text/html)
# Status: 200
```

### 2. Validate with Apple's Tool
- Go to: https://search.developer.apple.com/appsearch-validation-tool/
- Enter: `https://www.justdashapp.com`
- Should show valid association

### 3. Clear iOS Cache
On the test device:
1. Delete the app completely
2. Restart the device
3. Reinstall the app fresh from Xcode
4. Test immediately with a link from Messages

### 4. Xcode Settings
Verify in Xcode:
- Target → Signing & Capabilities → Associated Domains
- Should have: `applinks:www.justdashapp.com`
- Bundle Identifier: `com.csgergo.dash`
- Team ID: `8VZSVBTHF7`

### 5. Test the Link
Send this in Messages (not Safari address bar):
```
https://www.justdashapp.com/join/test123
```

Long-press the link - should show "Open in Dash" option

## Common Issues

### Issue 1: App Opens but Doesn't Join
**Symptoms:** Console shows "🔗 Universal Link received" but no "🎯 ContentView: handleDeepLink"

**Fix:** The `onChange` might not be firing. Check console logs.

### Issue 2: Opens in Safari Instead of App (iOS 18)
**Symptoms:** No app opening at all, just opens in browser

**Fixes:**
1. Update AASA to use `appIDs` (plural) and `components` format
2. Ensure AASA is served with `Content-Type: application/json`
3. No redirects on AASA file
4. Delete app, restart device, reinstall

### Issue 3: Works on Simulator but Not Device
**Fix:** Simulator doesn't validate AASA files. Always test on real device.

### Issue 4: "No app available to open this link"
**Fixes:**
1. Verify Bundle ID and Team ID match EXACTLY
2. Check Associated Domains capability is enabled in Apple Developer Portal
3. Ensure app is signed with correct provisioning profile

## iOS 18 Specific Notes

iOS 18 has stricter AASA validation:
- Must use HTTPS (not HTTP)
- No redirects allowed
- Content-Type MUST be `application/json`
- File must be at root domain (no www → non-www redirects)
- Consider using `appIDs` (plural) instead of `appID`

## Test Different Scenarios

1. **App Not Running:** Tap link → Should launch app and join
2. **App in Background:** Tap link → Should bring to foreground and join
3. **App in Foreground:** Tap link → Should process immediately

Check Xcode console for all scenarios!
