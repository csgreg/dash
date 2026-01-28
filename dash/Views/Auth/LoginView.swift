//
//  LoginView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import FirebaseAuth
import OSLog
import SwiftUI

struct LoginView: View {
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var signInFail: Bool = false
    @State private var loading: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var showPrivacyPolicy = false
    @StateObject private var googleSignInManager = GoogleSignInManager()
    @StateObject private var appleSignInManager = AppleSignInManager()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // Title and Subtitle
            VStack(spacing: 8) {
                Text("Good to see you! 👋")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.top, 24)
            .padding(.bottom, 40)

            // Form Section
            VStack(spacing: 16) {
                // email input
                HStack(spacing: 12) {
                    Image(systemName: "mail")
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .semibold))

                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .font(.system(size: 16, weight: .medium))

                    if !email.isEmpty {
                        Image(systemName: email.isValidEmail() ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(email.isValidEmail() ? .green : .red)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .modifier(GlassEffectIfAvailable())
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color("purple").opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)

                // password
                HStack(spacing: 12) {
                    Image(systemName: "lock")
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .semibold))

                    SecureField("Password", text: $password)
                        .font(.system(size: 16, weight: .medium))

                    if !password.isEmpty {
                        Image(systemName: password.isValidPassword() ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(password.isValidPassword() ? .green : .red)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .modifier(GlassEffectIfAvailable())
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color("purple").opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 24)

            // Forgot password button
            HStack {
                Spacer()
                Button(action: {
                    showForgotPassword = true
                }) {
                    Text("Forgot password?")
                        .foregroundColor(.secondary)
                        .font(.system(size: 15, weight: .medium))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Spacer()

            // sign in button
            Button(action: {
                loading = true
                AppLogger.auth.info("Email/password sign-in attempt")
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            AppLogger.auth.error("Email/password sign-in failed: \(error.localizedDescription)")
                            signInFail = true
                        }

                        if let authResult = authResult {
                            AppLogger.auth.notice("Email/password sign-in successful")
                            let uid = authResult.user.uid
                            withAnimation {
                                userID = uid
                            }
                            UserManager(userId: uid).fetchUserItemCount { _ in }
                            AnalyticsManager.logLoginSuccess(method: "password")
                        }
                        loading = false
                    }
                }
            }) {
                HStack(spacing: 8) {
                    if loading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                    }
                    Text("Sign In")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Color("purple"), in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                )
            }
            .modifier(GlassEffectIfAvailable())
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .disabled(loading)
            .alert(isPresented: $signInFail) {
                Alert(
                    title: Text("Login Failed"),
                    message: Text("Incorrect email or password. Please try again.")
                )
            }

            // Create account button
            Button(action: {
                withAnimation {
                    self.currentShowingView = "signup"
                }
            }) {
                Text("Create account")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color("purple"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                            .stroke(Color("purple").opacity(0.5), lineWidth: 1.5)
                    )
            }
            .modifier(GlassEffectIfAvailable())
            .padding(.horizontal, 24)
            .padding(.top, 12)

            // Divider with "OR"
            HStack {
                Rectangle()
                    .fill(.secondary.opacity(0.3))
                    .frame(height: 1)
                Text("OR")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                Rectangle()
                    .fill(.secondary.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // Apple and Google Sign In Buttons (side by side)
            HStack(spacing: 12) {
                // Apple Sign In Button
                AppleSignInButton(
                    action: {
                        appleSignInManager.signInWithApple { result in
                            switch result {
                            case let .success(uid):
                                withAnimation {
                                    userID = uid
                                }
                                UserManager(userId: uid).fetchUserItemCount { _ in }
                                AnalyticsManager.logLoginSuccess(method: "apple")
                            case let .failure(error):
                                signInFail = true
                                AppLogger.auth.error("Apple Sign-In failed: \(error.localizedDescription)")
                            }
                        }
                    },
                    isLoading: appleSignInManager.isLoading
                )

                // Google Sign In Button
                Button(action: {
                    googleSignInManager.signInWithGoogle { result in
                        switch result {
                        case let .success(uid):
                            withAnimation {
                                userID = uid
                            }
                            UserManager(userId: uid).fetchUserItemCount { _ in }
                            AnalyticsManager.logLoginSuccess(method: "google")
                        case let .failure(error):
                            signInFail = true
                            AppLogger.auth.error("Google Sign-In failed: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Image("google")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Color.white,
                            in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
                .disabled(googleSignInManager.isLoading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 32)

            // Privacy & Terms links
            HStack(spacing: 4) {
                Button(action: {
                    showPrivacyPolicy = true
                }) {
                    Text("Privacy Policy")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .underline()
                }

                Text("•")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Link("Apple's Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .underline()
            }
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            NavigationView {
                PrivacyPolicyView()
                    .navigationBarItems(trailing: Button("Done") {
                        showPrivacyPolicy = false
                    })
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(isPresented: $showForgotPassword)
                .presentationDetents([.fraction(0.4)])
        }
    }
}
