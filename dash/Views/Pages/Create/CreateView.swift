//
//  CreateView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 20.
//

import FirebaseCore
import FirebaseFirestore
import SwiftUI

struct CreateView: View {
    @State var listName: String = ""
    @State var selectedEmoji: String? = nil
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""

    @EnvironmentObject var listManager: ListManager

    private var isValidInput: Bool {
        if case .success = InputValidator.validateListName(listName) {
            return true
        }
        return false
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Description
                    Text(
                        "Craft customized lists for any purpose, share a unique code for seamless collaboration."
                    )
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color("dark-gray"))
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // List name input - liquid glass style
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Color("purple"))
                            .font(.system(size: 16, weight: .semibold))
                        TextField("List name", text: $listName)
                            .font(.system(size: 16, weight: .medium))

                        Spacer()

                        if !listName.isEmpty {
                            Image(systemName: isValidInput ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(isValidInput ? .green : .red)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                    )
                    .padding(.horizontal)

                    // Emoji selector
                    EmojiSelector(selectedEmoji: $selectedEmoji)
                        .padding(.horizontal)

                    Spacer()

                    // Create button - liquid glass style
                    Button(action: {
                        listManager.createList(listName: self.listName, emoji: self.selectedEmoji) { message in
                            self.alertMessage = message
                            self.showAlert = true
                            // Reset form on success
                            if message.contains("successfully") {
                                self.listName = ""
                                self.selectedEmoji = nil
                            }
                        }
                    }) {
                        Text("Create List")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                Color("purple"), in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                            )
                    }
                    .disabled(!isValidInput)
                    .opacity(isValidInput ? 1.0 : 0.5)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertMessage))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .navigationTitle("Create new list")
        }
    }
}

// MARK: - Emoji Selector Component

struct EmojiSelector: View {
    @Binding var selectedEmoji: String?
    @State private var isExpanded: Bool = false

    // Curated list of relevant emojis for lists
    let availableEmojis = [
        "📝", "✅", "📋", "📌", "🎯", "⭐", "❤️", "🔥",
        "🛒", "🛍️", "🎁", "🎉", "🎊", "🎈", "🎂", "🍕",
        "🍔", "🍿", "☕", "🍷", "🏠", "🏢", "🏫", "🏥",
        "✈️", "🚗", "🚲", "🏃", "💼", "📚", "🎓", "💡",
        "🎵", "🎬", "🎮", "🎨", "📷", "💰", "💳", "📱",
        "💻", "⌚", "🔔", "📅", "🗓️", "⏰", "🌟", "✨",
        "🌈", "☀️", "🌙", "⚡", "🔥", "💧", "🌿", "🌺",
        "🐶", "🐱", "🦊", "🐻", "🐼", "🦁", "🐸", "🦄",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with selected emoji or placeholder
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    // Emoji preview or placeholder
                    if let emoji = selectedEmoji {
                        Text(emoji)
                            .font(.system(size: 20))
                    } else {
                        Text("😊")
                            .font(.system(size: 20))
                            .opacity(0.4)
                    }

                    Text(selectedEmoji == nil ? "Select emoji (optional)" : "Change emoji")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.5))

                    Spacer()

                    // Clear button if emoji is selected
                    if selectedEmoji != nil {
                        Button(action: {
                            withAnimation {
                                selectedEmoji = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color("dark-gray").opacity(0.5))
                        }
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("purple"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }

            // Emoji grid (expanded)
            if isExpanded {
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 8), spacing: 12
                    ) {
                        ForEach(availableEmojis, id: \.self) { emoji in
                            Button(action: {
                                withAnimation {
                                    selectedEmoji = emoji
                                    isExpanded = false
                                }
                            }) {
                                Text(emoji)
                                    .font(.system(size: 28))
                                    .frame(width: 44, height: 44)
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
                    .padding(12)
                }
                .frame(maxHeight: 300)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
            .environmentObject(ListManager(userId: "asd"))
    }
}
