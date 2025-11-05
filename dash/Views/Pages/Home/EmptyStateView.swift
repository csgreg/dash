//
//  EmptyStateView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2025. 11. 03.
//

import SwiftUI

struct EmptyStateView: View {
    var onCreateList: () -> Void

    private let purpleColor = Color("purple")

    var body: some View {
        VStack(spacing: 24) {
            // Icon and Message
            VStack(spacing: 16) {
                // Empty box icon
                Image(systemName: "tray")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.white.opacity(0.7))

                VStack(spacing: 8) {
                    Text("Nothing here yet! 👀")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    Text("Time to create your first list\nand get organized!")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .padding(.top, 24)

            // Create List Button
            Button(action: onCreateList) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .semibold))

                    Text("Create Your First List")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(Color("purple"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Color.white,
                    in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                )
                .modifier(GlassEffectIfAvailable())
            }

            // Invite message
            VStack(spacing: 8) {
                Text("💡 Pro tip")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))

                Text("Once you create a list, you can invite\nfriends and family to collaborate!")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(.bottom, 24)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            .linearGradient(
                colors: [purpleColor.opacity(1), purpleColor.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .mask(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .shadow(color: purpleColor.opacity(0.3), radius: 8, x: 0, y: 12)
        .shadow(color: purpleColor.opacity(0.3), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(onCreateList: {})
    }
}
