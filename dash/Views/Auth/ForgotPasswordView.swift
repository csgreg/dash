//
//  ForgotPasswordView.swift
//  dash
//
//  Created by Gergo Csizmadia
//

import FirebaseAuth
import SwiftUI

struct ForgotPasswordView: View {
    @Binding var isPresented: Bool
    @State private var email: String = ""
    @State private var isLoading: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Main content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Reset Password")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)

                // Description
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                // Email input
                HStack(spacing: 12) {
                    Image(systemName: "mail")
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .semibold))

                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .font(.system(size: 16, weight: .medium))

                    if !email.isEmpty {
                        Image(systemName: email.isValidEmail() ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(email.isValidEmail() ? .green : .red)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color("purple").opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                // Send reset link button
                Button(action: {
                    sendPasswordResetEmail()
                }) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16, weight: .bold))
                        }
                        Text("Send Reset Link")
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
                .padding(.bottom, 24)
                .disabled(isLoading || !email.isValidEmail())
                .opacity((isLoading || !email.isValidEmail()) ? 0.6 : 1.0)
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
            )
            .padding(.horizontal, 32)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                isPresented = false
            }
        } message: {
            Text("Password reset email has been sent to \(email). Please check your inbox.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func sendPasswordResetEmail() {
        guard email.isValidEmail() else { return }

        isLoading = true

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            isLoading = false

            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            } else {
                showSuccessAlert = true
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(isPresented: .constant(true))
    }
}
