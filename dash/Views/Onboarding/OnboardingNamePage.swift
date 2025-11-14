//
//  OnboardingNamePage.swift
//  dash
//
//  First name collection page
//

import SwiftUI

struct OnboardingNamePage: View {
    @Binding var firstName: String
    var onComplete: () -> Void

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @FocusState private var isTextFieldFocused: Bool

    private var isValidName: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && firstName.count >= 2
    }

    var body: some View {
        ZStack {
            VStack {
                // Greeting icon
                ZStack {
                    Text("👋")
                        .font(.system(size: 70))
                        .scaleEffect(scale)
                        .padding(.top, 54)
                }
                .opacity(opacity)

                VStack(spacing: 16) {
                    Text("Nice to meet you!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(opacity)

                    Text("What should we call you?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                }
                .padding(.horizontal, 32)

                Spacer()

                // Name input field
                VStack(spacing: 24) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))

                        TextField("Your first name", text: $firstName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .accentColor(.white)
                            .focused($isTextFieldFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                if isValidName {
                                    completeOnboarding()
                                }
                            }

                        if !firstName.isEmpty {
                            Image(systemName: isValidName ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(isValidName ? .green : .red)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .modifier(GlassEffectIfAvailable())
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)

                    Text("This helps personalize your experience")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 32)
                .opacity(opacity)

                Spacer()

                // Get Started button
                Button(action: completeOnboarding) {
                    HStack(spacing: 12) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .bold))

                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(Color("purple"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Color.white,
                        in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                    )
                    .modifier(GlassEffectIfAvailable())
                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                }
                .disabled(!isValidName)
                .opacity(isValidName ? 1.0 : 0.5)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                scale = 1.0
                opacity = 1.0
            }

            // Auto-focus text field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }

    private func completeOnboarding() {
        guard isValidName else { return }

        // Hide keyboard
        isTextFieldFocused = false

        onComplete()
    }
}

// MARK: - Preview

struct OnboardingNamePage_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingNamePage(
            firstName: .constant(""),
            onComplete: {}
        )
    }
}
