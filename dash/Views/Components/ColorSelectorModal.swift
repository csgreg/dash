//
//  ColorSelectorModal.swift
//  dash
//
//  Created by Gergo Csizmadia on 2025. 11. 06.
//

import SwiftUI

struct ColorSelectorModal: View {
    @Binding var selectedColor: String?
    @Binding var isPresented: Bool
    @ObservedObject var rewardsManager: RewardsManager

    var body: some View {
        ZStack {
            // Invisible tap area to dismiss
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            // Modal content
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Select Color")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // Color grid - horizontal layout
                HStack(spacing: 16) {
                    ForEach(rewardsManager.achievements) { achievement in
                        let isUnlocked = rewardsManager.isColorUnlocked(achievement.unlockedColor)

                        Button(action: {
                            if isUnlocked {
                                withAnimation {
                                    selectedColor = achievement.unlockedColor
                                    isPresented = false
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        isUnlocked
                                            ? Color(achievement.unlockedColor)
                                            : Color.gray.opacity(0.3)
                                    )
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .opacity(selectedColor == achievement.unlockedColor ? 1 : 0)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color(achievement.unlockedColor), lineWidth: 3)
                                            .scaleEffect(1.15)
                                            .opacity(selectedColor == achievement.unlockedColor ? 0.5 : 0)
                                    )

                                if !isUnlocked {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(!isUnlocked)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)

                // Info text
                if rewardsManager.getUnlockedColors().count < rewardsManager.achievements.count {
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(Color("purple"))
                        Text("Complete achievements to unlock more colors")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()
                    .frame(height: 20)
            }
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}
