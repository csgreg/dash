//
//  LoginView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import FirebaseAuth
import SwiftUI

struct LoginView: View {
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var signInFail: Bool = false
    @State private var loading: Bool = false
    @StateObject private var googleSignInManager = GoogleSignInManager()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // App Logo
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            // Title and Subtitle
            VStack(spacing: 8) {
                Text("Welcome back!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.top, 24)
            .padding(.bottom, 40)

            // Form Section
            VStack(spacing: 16) {
                // email input
                HStack(spacing: 12) {
                    Image(systemName: "mail")
                        .foregroundColor(.black)
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
                        .foregroundColor(.black)
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
                    // TODO: Implement forgot password functionality
                    print("Forgot password tapped")
                }) {
                    Text("Forgot password?")
                        .foregroundColor(.gray)
                        .font(.system(size: 15, weight: .medium))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer()

            // sign in button
            Button(action: {
                loading = true
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if error != nil {
                        signInFail = true
                    }

                    if let authResult = authResult {
                        withAnimation {
                            userID = authResult.user.uid
                        }
                    }
                    loading = false
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
                    title: Text("Failed to log in"),
                    message: Text("Oops! Incorrect email or password.")
                )
            }

            // Divider with "OR"
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                Text("OR")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // Apple and Google Sign In Buttons (side by side)
            HStack(spacing: 12) {
                // Apple Sign In Button
                Button(action: {
                    // TODO: Implement Apple Sign-In when Apple Developer account is available
                    print("Apple Sign-In tapped - Not yet implemented")
                }) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Color.black,
                            in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                }

                // Google Sign In Button
                Button(action: {
                    googleSignInManager.signInWithGoogle { result in
                        switch result {
                        case let .success(uid):
                            withAnimation {
                                userID = uid
                            }
                        case let .failure(error):
                            signInFail = true
                            print("Google Sign-In Error: \(error.localizedDescription)")
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

            // Alternative Sign In label
            Text("Alternative Sign In")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray.opacity(0.7))
                .padding(.top, 8)

            Spacer()

            // Create account text link
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                    .font(.system(size: 15, weight: .regular))

                Button(action: {
                    withAnimation {
                        self.currentShowingView = "signup"
                    }
                }) {
                    Text("Create one!")
                        .foregroundColor(.black)
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .padding(.bottom, 40)
        }
    }
}
