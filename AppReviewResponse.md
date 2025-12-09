# App Review Response - Dash

## Issue 1: Sign in with Apple - RESOLVED ✅

**Problem:** App was requesting name/email after Sign in with Apple authentication.

**Solution Implemented:** 
- Modified `AppleSignInManager.swift` to automatically capture and save the user's first name from Apple's authentication response
- The name is now saved directly to Firebase when the user signs in with Apple (on first sign-in only, per Apple's design)
- Modified `OnboardingView.swift` to check if a name already exists in Firebase and skip the name entry screen if present
- Users who sign in with Apple and provide their name will see a 3-page onboarding (no name entry)
- Users who sign in with Google/Email or whose Apple account doesn't provide a name will see the standard 4-page onboarding with name entry

**Important Note About Apple Sign-In:**
Apple only provides the user's name on the very first authentication. On subsequent sign-ins, the name is not included in the response. Our implementation handles this by:
1. Saving the name to Firebase on first sign-in (when Apple provides it)
2. Checking Firebase for an existing name during onboarding
3. Only showing the name entry screen if no name exists in Firebase

This ensures users are never asked to re-enter information they've already provided through Apple Sign-In.

---

## Issue 2: Information About Business Model

### Response to App Review Questions:

**1. Who are the users that will use the paid subscriptions in the app?**

There are NO paid subscriptions or in-app purchases in the Dash app. The app is completely free to use with all features available to all users at no cost.

**2. Where can users purchase the subscriptions that can be accessed in the app?**

N/A - There are no subscriptions or purchases available in the app. Dash is a completely free app.

**3. What specific types of previously purchased subscriptions can a user access in the app?**

N/A - There are no subscriptions or purchases in the app.

**4. What paid content, subscriptions, or features are unlocked within your app that do not use in-app purchase?**

None. There is NO paid content whatsoever in the Dash app. All features are completely free:

**All Features (100% Free):**
- Creating unlimited lists
- Adding unlimited items
- Sharing lists with others via join codes
- Real-time collaboration with multiple users
- Offline access and sync
- Achievement system (unlock colors by creating items)
- Multiple color themes for lists
- Apple Sign In and Google Sign In authentication
- Account management

**Why Authentication is Required:**
Authentication (Apple Sign In / Google Sign In) is required solely for:
- Syncing lists across devices via Firebase
- Enabling real-time collaboration between users
- Securing user data
- Managing shared list permissions

Authentication does NOT gate any paid features - it's purely for the core free functionality of the app.

**5. Can users purchase physical goods or services together with digital content in your app? If so, please describe how the physical and digital content are connected and why you bundle them together in a single purchase.**

No. Dash does not sell ANY goods, services, or digital content. The app is completely free with no purchases of any kind.

---

## Summary

- **App Type:** Free Productivity/List Management & Collaboration Tool
- **Business Model:** Completely Free (no monetization)
- **All Features:** 100% Free - No IAP, No Subscriptions, No Paid Content
- **Authentication Purpose:** Required only for cloud sync and collaboration features
- **Revenue:** None - This is a free app
- **Physical Goods:** None
- **Digital Purchases:** None
- **Compliance:** Fully compliant - No purchases means no IAP requirements

