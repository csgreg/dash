//
//  GoogleSignInButton.swift
//  dash
//
//  Created by Gergo Csizmadia on 2025. 11. 05.
//

import SwiftUI

struct GoogleSignInButton: View {
    let action: () -> Void
    let isLoading: Bool

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                }

                Text("Continue with Google")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
            }
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
        .disabled(isLoading)
    }
}
