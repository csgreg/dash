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
    @State var showErrorAlert: Bool = false
    @State var errorMessage: String = ""
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

    private var createButton: some View {
        Button(action: {
            listManager.createList(listName: self.listName, emoji: self.selectedEmoji, color: self.selectedColor) { success, message in
                if success {
                    // Reset form and navigate to home on success
                    self.listName = ""
                    self.selectedEmoji = nil
                    self.selectedColor = "purple"
                    selectedTab = 0
                } else {
                    self.errorMessage = message
                    self.showErrorAlert = true
                }
            }
        }) {
            createButtonLabel
        }
        .modifier(GlassEffectIfAvailable())
        .disabled(!isValidInput)
        .opacity(isValidInput ? 1.0 : 0.5)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private var createButtonLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 20, weight: .bold))
            Text("Create List")
                .font(.system(size: 18, weight: .bold))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(buttonGradient)
        .cornerRadius(.infinity)
        .shadow(color: Color("purple").opacity(0.3), radius: 12, x: 0, y: 6)
    }

    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [Color("purple").opacity(1), Color("purple").opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var formScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                descriptionText
                listNameSection
                customizationSection
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
            }
        }
    }

    private var descriptionText: some View {
        Text(
            "Craft customized lists for any purpose, share a unique code for seamless collaboration."
        )
        .font(.system(size: 15, weight: .regular))
        .foregroundColor(Color("dark-gray"))
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private var listNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("List Name")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("dark-gray"))
                .padding(.horizontal, 24)

            HStack(spacing: 12) {
                Image(systemName: "pencil.line")
                    .foregroundColor(Color("purple"))
                    .font(.system(size: 16, weight: .semibold))

                TextField("Enter list name", text: $listName)
                    .font(.system(size: 16, weight: .medium))

                if !listName.isEmpty {
                    Image(systemName: isValidInput ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isValidInput ? .green : .red)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(.infinity)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }

    private var customizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Customize")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("dark-gray"))
                .padding(.horizontal, 24)

            VStack(spacing: 12) {
                EmojiSelectorButton(selectedEmoji: selectedEmoji, showModal: $showEmojiModal)
                ColorSelectorButton(selectedColor: selectedColor, showModal: $showColorModal)
            }
            .padding(.horizontal, 20)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                formScrollView

                // Fixed bottom button
                VStack {
                    Spacer()
                    createButton
                }
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
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
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
                        .font(.system(size: 24))
                } else {
                    ZStack {
                        Text("😊")
                            .font(.system(size: 20))
                            .opacity(0.5)
                    }
                }

                Text(selectedEmoji == nil ? "Select emoji" : "Change emoji")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("dark-gray"))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("purple").opacity(0.5))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(.infinity)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
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
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }

                Text("Change color")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("dark-gray"))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("purple").opacity(0.5))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(.infinity)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
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
