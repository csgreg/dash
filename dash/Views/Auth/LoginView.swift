//
//  LoginView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import FirebaseAuth
import RiveRuntime
import SwiftUI

struct LoginView: View {
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var signInFail: Bool = false
    @State private var loading: Bool = false

    var body: some View {
        ZStack {
            RiveViewModel(fileName: "shapes").view()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .blur(radius: 40)

            VStack {
                HStack {
                    Text("Welcome back!")
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
                .padding(.horizontal)

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
                .padding(.horizontal)

                // create account button
                Button(action: {
                    withAnimation {
                        self.currentShowingView = "signup"
                    }
                }) {
                    Text("New here? Sign up!")
                        .foregroundColor(.black)
                        .font(.system(size: 15, weight: .medium))
                }
                .padding(.top, 8)

                Spacer()
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
                    HStack(spacing: 1) {
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
                        .black, in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                    )
                }
                .modifier(GlassEffectIfAvailable())
                .padding(.horizontal)
                .disabled(loading)
                .alert(isPresented: $signInFail) {
                    Alert(
                        title: Text("Failed to log in"),
                        message: Text("Oops! Incorrect email or password.")
                    )
                }
                .padding(.bottom)
            }
        }
    }
}
