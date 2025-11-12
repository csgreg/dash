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
    @Binding var selectedTab: Int

    @State var listName: String = ""
    @State var selectedEmoji: String?
    @State var selectedColor: String? = "purple" // Auto-select first color
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""
    @State var showEmojiModal: Bool = false
    @State var showColorModal: Bool = false

    @EnvironmentObject var listManager: ListManager
    @StateObject private var rewardsManager = RewardsManager()

    private var isValidInput: Bool {
        if case .success = InputValidator.validateListName(listName) {
            return true
        }
        return false
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Description
                    Text(
                        "Craft customized lists for any purpose, share a unique code for seamless collaboration."
                    )
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color("dark-gray"))
                    .padding(.horizontal, 24)
                    .padding(.top, 4)

                    // List name input - with icon
                    HStack(spacing: 12) {
                        Image(systemName: "pencil.line")
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .semibold))

                        TextField("List name", text: $listName)
                            .font(.system(size: 16, weight: .medium))

                        if !listName.isEmpty {
                            Image(systemName: isValidInput ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(isValidInput ? .green : .red)
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
                    .padding(.horizontal, 20)

                    // Emoji selector button
                    EmojiSelectorButton(selectedEmoji: selectedEmoji, showModal: $showEmojiModal)
                        .padding(.horizontal, 20)

                    // Color selector button
                    ColorSelectorButton(selectedColor: selectedColor, showModal: $showColorModal)
                        .padding(.horizontal, 20)

                    Spacer(minLength: 40)

                    // Create button
                    Button(action: {
                        listManager.createList(listName: self.listName, emoji: self.selectedEmoji, color: self.selectedColor) { message in
                            self.alertMessage = message
                            self.showAlert = true
                            // Reset form and navigate to home on success
                            if message.contains("successfully") {
                                self.listName = ""
                                self.selectedEmoji = nil
                                self.selectedColor = nil
                                // Navigate to home page
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    selectedTab = 0
                                }
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("Create List")
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
                    .disabled(!isValidInput)
                    .opacity(isValidInput ? 1.0 : 0.6)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertMessage))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .navigationTitle("Let's do this! 🤩")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("Create new list")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
            .onAppear {
                rewardsManager.fetchUserItemCount(from: listManager)
            }
            .overlay(
                Group {
                    if showEmojiModal {
                        EmojiSelectorModal(selectedEmoji: $selectedEmoji, isPresented: $showEmojiModal)
                            .transition(.opacity)
                    }
                }
            )
            .overlay(
                Group {
                    if showColorModal {
                        ColorSelectorModal(selectedColor: $selectedColor, isPresented: $showColorModal, rewardsManager: rewardsManager)
                            .transition(.opacity)
                    }
                }
            )
        }
    }
}

// MARK: - Emoji Selector Button Component

struct EmojiSelectorButton: View {
    let selectedEmoji: String?
    @Binding var showModal: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                showModal = true
            }
        }) {
            HStack(spacing: 12) {
                // Emoji preview or placeholder
                if let emoji = selectedEmoji {
                    Text(emoji)
                        .font(.system(size: 22))
                } else {
                    Text("😊")
                        .font(.system(size: 22))
                        .opacity(0.4)
                }

                Text(selectedEmoji == nil ? "Select emoji (optional)" : "Change emoji")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.gray.opacity(0.5))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("purple"))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .modifier(GlassEffectIfAvailable())
            .overlay(
                RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                    .stroke(Color("purple").opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Color Selector Button Component

struct ColorSelectorButton: View {
    let selectedColor: String?
    @Binding var showModal: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                showModal = true
            }
        }) {
            HStack(spacing: 12) {
                // Color preview
                if let colorName = selectedColor {
                    Circle()
                        .fill(Color(colorName))
                        .frame(width: 26, height: 26)
                }

                Text("Change color")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.gray.opacity(0.5))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("purple"))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .modifier(GlassEffectIfAvailable())
            .overlay(
                RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                    .stroke(Color("purple").opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Preview

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView(selectedTab: .constant(1))
            .environmentObject(ListManager(userId: "asd"))
    }
}
