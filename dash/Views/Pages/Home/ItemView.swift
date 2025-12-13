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

    let editingItemId: String?
    @Binding var editingText: String
    let isEditInteractionDisabled: Bool
    let onStartEditing: (Item) -> Void
    let onSaveEditing: () -> Void
    @FocusState.Binding var focusedField: ListDetailsView.FocusField?

    @EnvironmentObject var listManager: ListManager

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
                .disabled(isEditInteractionDisabled)

                // Item text or edit field
                if editingItemId == currentItem.id {
                    TextField("Item name", text: $editingText)
                        .font(.system(size: 16, weight: .medium))
                        .focused($focusedField, equals: .editItem(currentItem.id))
                        .onSubmit {
                            onSaveEditing()
                        }
                } else {
                    Text(currentItem.text)
                        .font(.system(size: 16, weight: .medium))
                        .strikethrough(currentItem.done)
                        .foregroundColor(currentItem.done ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            guard !isEditInteractionDisabled else { return }
                            onStartEditing(currentItem)
                        }
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                // Left swipe: Edit
                Button {
                    guard !isEditInteractionDisabled else { return }
                    onStartEditing(currentItem)
                } label: {
                    Image(systemName: "pencil")
                }
                .tint(.blue)
                .disabled(isEditInteractionDisabled)
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
                .disabled(isEditInteractionDisabled)
            }
            .transition(.scale)
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        @FocusState var focusedField: ListDetailsView.FocusField?
        return ItemView(
            item: Item(id: "1", text: "rama margarin", done: false),
            listId: "alma",
            editingItemId: nil,
            editingText: .constant(""),
            isEditInteractionDisabled: false,
            onStartEditing: { _ in },
            onSaveEditing: {},
            focusedField: $focusedField
        )
        .environmentObject(ListManager(userId: "preview"))
    }
}
