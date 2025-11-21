//
//  AppleSignInButton.swift
//  dash
//
//  Created by Gergo Csizmadia on 2025. 11. 05.
//

import SwiftUI

struct AppleSignInButton: View {
    let action: () -> Void
    let isLoading: Bool

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Color.black,
                in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading)
    }
}
