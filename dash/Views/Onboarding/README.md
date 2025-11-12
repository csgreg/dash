# Onboarding Flow

## Overview
A beautiful, modern onboarding experience for new Dash users with glass effects and smooth animations.

## Features

### 📱 Four-Page Carousel
1. **Welcome Page** - Introduction to Dash with key features
2. **Collaboration Page** - Real-time sharing and sync features
3. **Rewards Page** - Gamification and unlock system
4. **Name Collection** - Personalized greeting

### ✨ Design Elements
- **Animated gradient background** - Smooth color transitions
- **Glass morphism effects** - iOS 18+ compatible with fallbacks
- **Smooth animations** - Spring-based transitions
- **Custom page indicators** - Animated dots
- **Skip functionality** - Optional quick exit

### 🎨 iOS Compatibility
- **iOS 26+**: Uses modern glass effects and materials
- **iOS 25 and below**: Graceful fallback with ultraThinMaterial
- All animations work across versions

## Files Structure

```
Views/Onboarding/
├── OnboardingView.swift          # Main container with TabView
├── OnboardingPages.swift         # Pages 1-3 (Welcome, Collab, Rewards)
├── OnboardingNamePage.swift      # Page 4 (Name collection + celebration)
└── README.md                     # This file
```

## Integration

The onboarding is automatically shown to new users after signup via `ContentView.swift`:

```swift
@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

// In body
if !hasCompletedOnboarding {
    OnboardingView()
}
```

## User Flow

1. User signs up → `hasCompletedOnboarding = false`
2. `OnboardingView` is displayed
3. User swipes through 3 intro pages (or skips)
4. User enters their first name
5. Celebration animation plays
6. `hasCompletedOnboarding = true` → User sees main app
7. First name is saved to Firebase

## Customization

### Colors
- Primary: `Color("purple")` from asset catalog
- Accents: White with various opacities
- Celebration: Multi-color confetti

### Animations
- Page transitions: Spring (response: 0.6, damping: 0.8)
- Element reveals: Spring (response: 0.8, damping: 0.7)
- Gradient: EaseInOut 3s repeat forever

### Text Content
All text is easily editable in the respective page files:
- `OnboardingPage1` - Welcome message
- `OnboardingPage2` - Collaboration features
- `OnboardingPage3` - Rewards system
- `OnboardingNamePage` - Name prompt

## Testing

To test onboarding again:
1. Reset UserDefaults: `UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")`
2. Or delete and reinstall the app

## Future Enhancements

Potential improvements:
- [ ] Add haptic feedback on page changes
- [ ] Localization support
- [ ] A/B testing different content
- [ ] Analytics tracking
- [ ] Video/Lottie animations
- [ ] Interactive tutorials
