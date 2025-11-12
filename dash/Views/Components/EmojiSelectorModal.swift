//
//  EmojiSelectorModal.swift
//  dash
//
//  Created by Gergo Csizmadia on 2025. 11. 06.
//

import SwiftUI

struct EmojiSelectorModal: View {
    @Binding var selectedEmoji: String?
    @Binding var isPresented: Bool

    // Curated list of relevant emojis for lists - 4 rows
    let availableEmojis = [
        "📝", "✅", "📋", "📌", "🎯", "⭐",
        "❤️", "🔥", "🛒", "🛍️", "🎁", "🎉",
        "🏠", "🏢", "✈️", "🚗", "💼", "📚",
        "🎵", "🎬", "🎮", "🎨", "💰", "📱",
    ]

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
                    Text("Select Emoji")
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

                // Emoji grid - 4 rows, 6 columns
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6),
                    spacing: 12
                ) {
                    ForEach(availableEmojis, id: \.self) { emoji in
                        Button(action: {
                            withAnimation {
                                selectedEmoji = emoji
                                isPresented = false
                            }
                        }) {
                            Text(emoji)
                                .font(.system(size: 32))
                                .frame(width: 50, height: 50)
                                .background(
                                    selectedEmoji == emoji
                                        ? Color("purple").opacity(0.2)
                                        : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color("purple"), lineWidth: selectedEmoji == emoji ? 2 : 0)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Clear button
                if selectedEmoji != nil {
                    Button(action: {
                        withAnimation {
                            selectedEmoji = nil
                            isPresented = false
                        }
                    }) {
                        Text("Clear Selection")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Color.red.opacity(0.1),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
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
