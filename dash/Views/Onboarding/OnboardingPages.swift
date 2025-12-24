//
//  OnboardingPages.swift
//  dash
//
//  Individual onboarding page components
//

import SwiftUI

// MARK: - Page 1: Welcome & Introduction

struct OnboardingPage1: View {
    var body: some View {
        VStack {
            // Illustration
            ZStack {
                // Background circles
                Circle()
                    .fill(Color.white.opacity(0))
                    .frame(width: 120, height: 120)

                // Main emoji
                Image("confetti")
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 120)
            }
            .drawingGroup()
            VStack(spacing: 16) {
                Text("Welcome to Dash!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Create your first list and start organizing your life!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)

            Spacer()

            // Feature highlights
            VStack(spacing: 16) {
                FeatureHighlight(
                    icon: "list.bullet.rectangle.fill",
                    title: "Create Lists",
                    description: "Organize anything, anytime"
                )

                FeatureHighlight(
                    icon: "person.2.fill",
                    title: "Collaborate",
                    description: "Share with friends & family"
                )

                FeatureHighlight(
                    icon: "checkmark.circle.fill",
                    title: "Stay Synced",
                    description: "Real-time updates across"
                )
            }
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Page 2: Collaboration Features

struct OnboardingPage2: View {
    var body: some View {
        VStack {
            // Illustration
            ZStack {
                // Background circles
                Circle()
                    .fill(Color.white.opacity(0))
                    .frame(width: 120, height: 120)

                // Main emoji
                Image("collaborate")
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 120)
            }
            .drawingGroup()

            VStack(spacing: 16) {
                Text("Share & Collaborate")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(
                    "Share lists with anyone using a simple invite link. Everyone stays in sync instantly!"
                )
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // Glass card with features
            VStack(spacing: 20) {
                CollaborationFeature(
                    icon: "link.circle.fill",
                    title: "Easy Sharing",
                    description: "Generate & share invite links"
                )

                CollaborationFeature(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Live Updates",
                    description: "Changes sync automatically"
                )

                CollaborationFeature(
                    icon: "person.3.fill",
                    title: "Work Together",
                    description: "Multiple people, one shared list"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Page 3: Rewards & Gamification

struct OnboardingPage3: View {
    var body: some View {
        VStack {
            // Illustration
            ZStack {
                // Background circles
                Circle()
                    .fill(Color.white.opacity(0))
                    .frame(width: 120, height: 120)

                // Main emoji
                Image("trophy")
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 120)
            }
            .drawingGroup()

            VStack(spacing: 16) {
                Text("Level Up!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Complete tasks and unlock exclusive colors and features as you go!")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // Reward tiers
            VStack(spacing: 16) {
                RewardTier(
                    icon: "star.fill",
                    title: "Complete Tasks",
                    description: "Create items to earn points",
                    color: .white
                )

                RewardTier(
                    icon: "paintpalette.fill",
                    title: "Unlock Colors",
                    description: "New themes as you progress",
                    color: .white
                )

                RewardTier(
                    icon: "sparkles",
                    title: "Keep Going",
                    description: "More rewards coming soon",
                    color: .white
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Supporting Components

struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct CollaborationFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
    }
}

struct RewardTier: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
    }
}

// MARK: - Previews

struct OnboardingPages_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingPage1()
            OnboardingPage2()
            OnboardingPage3()
        }
    }
}
