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
        NavigationView {
            VStack(spacing: 24) {
                // Description
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                // Email input
                HStack(spacing: 12) {
                    Image(systemName: "mail")
                        .foregroundColor(.primary)
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
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
        }
        .presentationBackground(Color(UIColor.systemBackground))
        .alert("Password Reset Sent", isPresented: $showSuccessAlert) {
            Button("OK") {
                isPresented = false
            }
        } message: {
            Text("We've sent a password reset link to \(email). Please check your inbox or spam folder.")
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
