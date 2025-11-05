//
//  SignupView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import FirebaseAuth
import SwiftUI

struct SignupView: View {
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var verifyPassword: String = ""
    @State private var signUpFail = false
    @State private var failTitle = ""
    @State private var loading: Bool = false
    @StateObject private var googleSignInManager = GoogleSignInManager()

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Text("Create an account!")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                .padding()
                .padding(.top)

                Spacer()

                // email input
                HStack(spacing: 12) {
                    Image(systemName: "mail")
                        .foregroundColor(.white)
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
                .padding(.horizontal)

                // password
                HStack(spacing: 12) {
                    Image(systemName: "lock")
                        .foregroundColor(.white)
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
                .padding(.horizontal)

                // password confirm
                HStack(spacing: 12) {
                    Image(systemName: "lock")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))

                    SecureField("Verify Password", text: $verifyPassword)
                        .font(.system(size: 16, weight: .medium))

                    if !verifyPassword.isEmpty {
                        Image(systemName: verifyPassword.isValidPassword() ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(verifyPassword.isValidPassword() ? .green : .red)
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
                .padding(.horizontal)

                // Divider with "OR"
                HStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                    Text("OR")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal)
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
                                signUpFail = true
                                failTitle = error.localizedDescription
                            }
                        }
                    },
                    isLoading: googleSignInManager.isLoading
                )
                .padding(.horizontal)
                .padding(.top, 16)

                // sign in button
                Button(action: {
                    withAnimation {
                        self.currentShowingView = "login"
                    }
                }) {
                    Text("Have an account? Sign in!")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .medium))
                }
                .padding(.top, 16)

                Spacer()
                Spacer()

                // create account button
                Button(action: {
                    loading = true
                    if !email.isValidEmail() {
                        signUpFail = true
                        failTitle = "Please type a correct email address!"
                        loading = false
                        return
                    }
                    if !password.isValidPassword() {
                        signUpFail = true
                        failTitle = "Password must be at least 8 characters long!"
                        loading = false
                        return
                    }
                    if password != verifyPassword {
                        signUpFail = true
                        failTitle = "Passwords do not match. Please try again."
                        loading = false
                        return
                    }

                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if error != nil {
                            signUpFail = true
                            failTitle = "Please try again later or check your internet connection!"
                            loading = false
                            return
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
                            Image(systemName: "person.badge.plus.fill")
                                .font(.system(size: 18, weight: .bold))
                        }
                        Text("Create Account")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Color("purple"), in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                    )
                    .shadow(color: Color("purple").opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .disabled(loading)
                .modifier(GlassEffectIfAvailable())
                .padding(.horizontal)
                .alert(isPresented: $signUpFail) {
                    Alert(
                        title: Text("Failed to sign up"),
                        message: Text(failTitle)
                    )
                }
                .padding(.bottom)
            }
        }
    }
}
