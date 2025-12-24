//
//  ListDetailsOnboarding.swift
//  dash
//
//  Onboarding flow for list details screen
//

import SwiftUI

struct ListDetailsOnboarding: View {
    @AppStorage("hasSeenListDetailsOnboarding") private var hasSeenListDetailsOnboarding: Bool = false

    @State private var currentPage: Int = 0
    private let totalPages = 2

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background to dim content and block interaction
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    // Block interaction with content underneath
                }

            // Centered card
            VStack(spacing: 0) {
                // Title at the top
                Text(currentPage == 0 ? "Add & Organize Items" : "Share & Collaborate")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 30)
                    .padding(.horizontal, 20)

                // Page content
                TabView(selection: $currentPage) {
                    ListDetailsOnboardingPage1()
                        .tag(0)

                    ListDetailsOnboardingPage2()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                .frame(height: 280)

                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0 ..< totalPages, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color("purple") : Color.gray.opacity(0.3))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Next/Done button
                Button(action: {
                    if currentPage < totalPages - 1 {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    HStack(spacing: 12) {
                        Text(currentPage == totalPages - 1 ? "Got it!" : "Continue")
                            .font(.system(size: 17, weight: .bold))

                        Image(systemName: currentPage == totalPages - 1 ? "checkmark" : "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Color("purple"),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 24, x: 0, y: 12)
            .padding(.horizontal, 32)
        }
    }

    private func completeOnboarding() {
        hasSeenListDetailsOnboarding = true
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            onComplete()
        }
    }
}

// MARK: - Page 1: Add Items

struct ListDetailsOnboardingPage1: View {
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Text("Everything you need to manage your list")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)

            // Feature highlights
            VStack(spacing: 14) {
                OnboardingFeature(
                    icon: "checkmark.circle.fill",
                    title: "Complete",
                    description: "Tap the checkbox to mark as done"
                )

                OnboardingFeature(
                    icon: "pencil",
                    title: "Edit",
                    description: "Tap item text or swipe left to edit"
                )

                OnboardingFeature(
                    icon: "trash",
                    title: "Delete",
                    description: "Swipe right to delete item"
                )

                OnboardingFeature(
                    icon: "arrow.up.arrow.down",
                    title: "Reorder",
                    description: "Tap Edit, then drag to reorder"
                )
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                opacity = 1.0
            }
        }
    }
}

// MARK: - Page 2: Collaborate

struct ListDetailsOnboardingPage2: View {
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text("Use the")
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14, weight: .medium))
                Text("menu to share and manage.")
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)

            // Feature highlights
            VStack(spacing: 14) {
                OnboardingFeature(
                    icon: "square.and.arrow.up",
                    title: "Share List",
                    description: "Invite others with a link"
                )

                OnboardingFeature(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Real-time Sync",
                    description: "Changes appear instantly"
                )

                OnboardingFeature(
                    icon: "slider.horizontal.3",
                    title: "List Settings",
                    description: "Rename, change emoji or color"
                )

                OnboardingFeature(
                    icon: "ellipsis.circle",
                    title: "List Options",
                    description: "Complete all, clear, or delete list"
                )
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                opacity = 1.0
            }
        }
    }
}

// MARK: - Supporting Component

struct OnboardingFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("purple"))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color("purple").opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

struct ListDetailsOnboarding_Previews: PreviewProvider {
    static var previews: some View {
        ListDetailsOnboarding(onComplete: {})
    }
}
