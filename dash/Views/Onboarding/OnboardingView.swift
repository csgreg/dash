//
//  OnboardingView.swift
//  dash
//
//  Created for onboarding flow
//

import OSLog
import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("uid") var userID: String = ""

    @State private var currentPage: Int = 0
    @State private var firstName: String = ""
    @State private var showNameInput: Bool = false
    @State private var isCompleting: Bool = false

    private let totalPages = 4 // 3 intro pages + 1 name collection

    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < totalPages - 1 {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                completeOnboarding()
                            }
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Page content
                TabView(selection: $currentPage) {
                    OnboardingPage1()
                        .tag(0)

                    OnboardingPage2()
                        .tag(1)

                    OnboardingPage3()
                        .tag(2)

                    OnboardingNamePage(
                        firstName: $firstName,
                        onComplete: completeOnboarding
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0 ..< totalPages, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 20)

                // Next/Continue button
                if currentPage < totalPages - 1 {
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text(currentPage == totalPages - 2 ? "Let's Start" : "Continue")
                                .font(.system(size: 18, weight: .bold))

                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(Color("purple"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Color.white,
                            in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                        )
                        .modifier(GlassEffectIfAvailable())
                        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 12)
                }
            }
        }
    }

    private func completeOnboarding() {
        isCompleting = true

        // Save first name if provided
        if !firstName.isEmpty {
            let userManager = UserManager(userId: userID)
            userManager.saveUserFirstName(firstName) { error in
                if let error = error {
                    AppLogger.database.error("Failed to save first name: \(error.localizedDescription)")
                }
            }
        }

        // Mark onboarding as completed with a slight delay for animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                hasCompletedOnboarding = true
            }
        }
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    private let purpleColor = Color("purple")

    var body: some View {
        LinearGradient(
            colors: [
                purpleColor.opacity(0.7),
                purpleColor.opacity(0.9),
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
