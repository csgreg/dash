//
//  ItemView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 26.
//

import SwiftUI

struct ItemView: View {
    let item: Item
    let listId: String

    @EnvironmentObject var listManager: ListManager
    @State private var isEditing = false
    @State private var editedText = ""
    @FocusState private var isFocused: Bool

    private var currentItem: Item? {
        listManager.lists
            .first(where: { $0.id == listId })?
            .items
            .first(where: { $0.id == item.id })
    }

    var body: some View {
        if let currentItem = currentItem {
            HStack(spacing: 12) {
                // Round checkbox
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        if currentItem.done {
                            listManager.unDoneItemInList(listId: listId, itemId: currentItem.id)
                        } else {
                            listManager.doneItemInList(listId: listId, itemId: currentItem.id)
                        }
                    }
                } label: {
                    Image(systemName: currentItem.done ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(currentItem.done ? .green : .gray)
                }
                .buttonStyle(.plain)

                // Item text or edit field
                if isEditing {
                    HStack(spacing: 8) {
                        TextField("Item name", text: $editedText)
                            .font(.system(size: 16, weight: .medium))
                            .focused($isFocused)
                            .onSubmit {
                                saveEdit()
                            }

                        Button {
                            saveEdit()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Text(currentItem.text)
                        .font(.system(size: 16, weight: .medium))
                        .strikethrough(currentItem.done)
                        .foregroundColor(currentItem.done ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            startEditing()
                        }
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                // Left swipe: Edit
                Button {
                    startEditing()
                } label: {
                    Image(systemName: "pencil")
                }
                .tint(.blue)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                // Right swipe: Delete
                Button(role: .destructive) {
                    withAnimation(.spring(response: 0.3)) {
                        listManager.deleteItemFromList(listId: listId, itemId: currentItem.id)
                    }
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
            }
            .transition(.scale)
        }
    }

    private func startEditing() {
        guard let currentItem = currentItem else { return }
        editedText = currentItem.text
        withAnimation {
            isEditing = true
        }
        // Focus after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isFocused = true
        }
    }

    private func saveEdit() {
        guard !editedText.trimmingCharacters(in: .whitespaces).isEmpty else {
            cancelEdit()
            return
        }

        listManager.updateItemText(listId: listId, itemId: item.id, newText: editedText)

        withAnimation {
            isEditing = false
        }
        isFocused = false
    }

    private func cancelEdit() {
        withAnimation {
            isEditing = false
        }
        isFocused = false
        editedText = ""
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(item: Item(id: "1", text: "rama margarin", done: false), listId: "alma")
    }
}
