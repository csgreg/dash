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

    let isHeaderCollapsed: Bool
    let isSectionCollapseDisabled: Bool
    let onToggleKind: (Item) -> Void
    let onToggleCollapse: (Item) -> Void

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
                if currentItem.kind == .task {
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
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                    .disabled(isEditInteractionDisabled)
                }

                if editingItemId == currentItem.id {
                    TextField("Item name", text: $editingText)
                        .font(.system(size: 16, weight: .medium))
                        .focused($focusedField, equals: .editItem(currentItem.id))
                        .onSubmit {
                            onSaveEditing()
                        }
                } else {
                    Text(currentItem.text)
                        .font(.system(size: 16, weight: currentItem.kind == .header ? .semibold : .medium))
                        .strikethrough(currentItem.kind == .task && currentItem.done)
                        .foregroundColor((currentItem.kind == .task && currentItem.done) ? .secondary : .primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            guard !isEditInteractionDisabled else { return }
                            onStartEditing(currentItem)
                        }
                }

                if currentItem.kind == .header {
                    Button {
                        onToggleCollapse(currentItem)
                    } label: {
                        Image(systemName: isHeaderCollapsed ? "chevron.down" : "chevron.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(isEditInteractionDisabled || isSectionCollapseDisabled)
                }
            }
            .frame(minHeight: currentItem.kind == .header ? 24 : nil)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                Button {
                    guard !isEditInteractionDisabled else { return }
                    onToggleKind(currentItem)
                } label: {
                    Image(systemName: currentItem.kind == .header ? "checkmark.circle" : "text.badge.checkmark")
                }
                .tint(currentItem.kind == .header ? .gray : .purple)
                .disabled(isEditInteractionDisabled)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
            isHeaderCollapsed: false,
            isSectionCollapseDisabled: false,
            onToggleKind: { _ in },
            onToggleCollapse: { _ in },
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
