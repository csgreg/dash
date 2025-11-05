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

                Text("Sign in to continue")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
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

            // create account button
            Button(action: {
                withAnimation {
                    self.currentShowingView = "signup"
                }
            }) {
                Text("New here? Sign up!")
                    .foregroundColor(.black)
                    .font(.system(size: 17, weight: .medium))
            }
            .padding(.top, 16)

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
                    Color("red"), in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                )
            }
            .modifier(GlassEffectIfAvailable())
            .padding(.horizontal, 24)
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

            // Google Sign In Button
            GoogleSignInButton(
                action: {
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
                },
                isLoading: googleSignInManager.isLoading
            )
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }
}
