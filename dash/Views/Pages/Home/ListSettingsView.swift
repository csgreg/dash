//
//  ListSettingsView.swift
//  dash
//
//  List settings overlay for owners to edit list properties
//

import SwiftUI

struct ListSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject private var rewardsManager: RewardsManager

    let listId: String
    let currentName: String
    let currentEmoji: String?
    let currentColor: String?

    @State private var listName: String
    @State private var selectedEmoji: String?
    @State private var selectedColor: String?
    @State private var showEmojiModal: Bool = false
    @State private var showColorModal: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    init(listId: String, currentName: String, currentEmoji: String?, currentColor: String?) {
        self.listId = listId
        self.currentName = currentName
        self.currentEmoji = currentEmoji
        self.currentColor = currentColor

        _listName = State(initialValue: currentName)
        _selectedEmoji = State(initialValue: currentEmoji)
        _selectedColor = State(initialValue: currentColor ?? "purple")
    }

    private var isValidInput: Bool {
        if case .success = InputValidator.validateListName(listName) {
            return true
        }
        return false
    }

    private var hasChanges: Bool {
        return listName != currentName ||
            selectedEmoji != currentEmoji ||
            selectedColor != currentColor
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    descriptionText
                    listNameSection
                    customizationSection
                }
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .navigationTitle("List Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValidInput || !hasChanges)
                }
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

    private var descriptionText: some View {
        Text("Give your list a fresh new look! ✨")
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(.secondary)
            .padding(.horizontal, 24)
    }

    private var listNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("List Name")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
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
            .modifier(GlassEffectIfAvailable())
            .padding(.horizontal, 20)
        }
    }

    private var customizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Customize")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)

            VStack(spacing: 12) {
                EmojiSelectorButton(selectedEmoji: selectedEmoji, showModal: $showEmojiModal)
                ColorSelectorButton(selectedColor: selectedColor, showModal: $showColorModal)
            }
            .padding(.horizontal, 20)
        }
    }

    private func saveChanges() {
        listManager.updateList(
            listId: listId,
            listName: listName,
            emoji: selectedEmoji,
            color: selectedColor
        ) { success, message in
            if success {
                dismiss()
            } else {
                errorMessage = message
                showErrorAlert = true
            }
        }
    }
}

struct ListSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ListSettingsView(
            listId: "test",
            currentName: "My List",
            currentEmoji: "📝",
            currentColor: "purple"
        )
        .environmentObject(ListManager(userId: "test"))
    }
}
