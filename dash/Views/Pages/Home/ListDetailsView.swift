//
//  ListDetailsView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 19.
//

import SwiftUI

struct ListDetailsView: View {
    @State private var newItem: String = ""
    @State private var showClearConfirmation = false
    @State private var showDeleteConfirmation = false

    let listId: String

    @EnvironmentObject var listManager: ListManager

    // Computed property to get the current list from ListManager
    private var list: Listy? {
        listManager.lists.first(where: { $0.id == listId })
    }

    private var isValidInput: Bool {
        if case .success = InputValidator.validateItemName(newItem) {
            return true
        }
        return false
    }

    var body: some View {
        ZStack {
            List {
                ForEach(list?.items ?? []) { item in
                    ItemView(item: item, listId: listId)
                }
                .onMove { from, moveTo in
                    guard let listIndex = listManager.lists.firstIndex(where: { $0.id == listId }) else {
                        return
                    }

                    // Update the actual list in listManager for immediate UI feedback
                    listManager.lists[listIndex].items.move(fromOffsets: from, toOffset: moveTo)

                    // Batch update all item orders in Firestore with a single request
                    let itemsToUpdate = listManager.lists[listIndex].items.enumerated().map { index, item in
                        (itemId: item.id, order: index)
                    }
                    listManager.updateMultipleItemOrders(listId: listId, items: itemsToUpdate)
                }
            }
            .preferredColorScheme(.light)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }

            // Bottom section with liquid glass background - overlaid on top
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    HStack {
                        // add item input - liquid glass style
                        HStack {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(Color("purple"))
                                .font(.system(size: 16, weight: .semibold))
                            TextField("Item Name", text: $newItem)
                                .font(.system(size: 16, weight: .medium))

                            Spacer()

                            if !newItem.isEmpty {
                                Image(systemName: isValidInput ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(isValidInput ? .green : .red)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .modifier(GlassEffectIfAvailable())
                        .padding(.leading)

                        // add item button - liquid glass style
                        Button(
                            action: {
                                guard let currentList = list else { return }
                                let item = Item(id: UUID().uuidString, text: newItem, order: currentList.items.count)
                                listManager.addItemToList(listId: listId, item: item)
                                newItem = ""
                            },
                            label: {
                                Text("Add")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(
                                        Color("purple"), in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    )
                                    .frame(maxWidth: 100)
                            }
                        )
                        .disabled(!isValidInput)
                        .opacity(isValidInput ? 1.0 : 0.5)
                        .modifier(GlassEffectIfAvailable())
                        .padding(.trailing)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    if let emoji = list?.emoji {
                        Text(emoji)
                            .font(.system(size: 20))
                    }
                    Text(list?.name ?? "")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(
                    content: {
                        Button(
                            action: {
                                if let shareURL = DeepLinkHandler.generateShareURL(for: listId) {
                                    let message = "Join my list '\(list?.name ?? "Untitled")' on Dash!"
                                    let activityVC = UIActivityViewController(
                                        activityItems: [message, shareURL], applicationActivities: nil
                                    )
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let rootViewController = windowScene.windows.first?.rootViewController
                                    {
                                        rootViewController.present(activityVC, animated: true, completion: nil)
                                    }
                                }
                            },
                            label: {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                        )

                        Divider()

                        Button(
                            action: {
                                listManager.markAllItemsAsDone(listId: listId)
                            },
                            label: {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Complete All")
                            }
                        )
                        .disabled((list?.items.isEmpty ?? true))

                        Button(
                            action: {
                                listManager.markAllItemsAsUndone(listId: listId)
                            },
                            label: {
                                Image(systemName: "circle")
                                Text("Reset All")
                            }
                        )
                        .disabled((list?.items.isEmpty ?? true))

                        Divider()

                        Button(
                            action: {
                                showClearConfirmation = true
                            },
                            label: {
                                Image(systemName: "sparkles")
                                Text("Clear List")
                            }
                        )
                        .disabled((list?.items.isEmpty ?? true))

                        Button(
                            action: {
                                showDeleteConfirmation = true
                            },
                            label: {
                                Image(systemName: "trash")
                                Text("Delete List")
                            }
                        )
                    },
                    label: {
                        Image(systemName: "gearshape.fill")
                    }
                )
            }
        }
        .confirmationDialog(
            "Clear All Items",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear All Items", role: .destructive) {
                listManager.clearAllItems(listId: listId)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all \(list?.items.count ?? 0) items from this list. This action cannot be undone.")
        }
        .confirmationDialog(
            "Delete List",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete List", role: .destructive) {
                listManager.deleteList(listId: listId)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete the list '\(list?.name ?? "Untitled")' and all its items. This action cannot be undone.")
        }
    }
}

struct ListDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ListDetailsView(listId: "2")
            .environmentObject(ListManager(userId: "asd"))
    }
}
