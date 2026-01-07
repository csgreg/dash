//
//  ListDetailsView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 19.
//

import Foundation
import SwiftUI

struct ListDetailsView: View {
    @State private var newItem: String = ""
    @State private var editingItemId: String?
    @State private var editingText: String = ""
    @State private var isSavingEdit: Bool = false
    @State private var collapsedHeaderIds: Set<String> = []
    @State private var didLoadCollapsedState: Bool = false
    @State private var showClearConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showLeaveConfirmation = false
    @State private var showListSettings = false
    @AppStorage("hasSeenListDetailsOnboarding") private var hasSeenListDetailsOnboarding: Bool = false
    @State private var showListDetailsOnboarding: Bool = false

    enum FocusField: Hashable {
        case editItem(String)
    }

    @FocusState private var focusedField: FocusField?
    @Environment(\.editMode) private var editMode

    let listId: String

    @EnvironmentObject var listManager: ListManager

    // Computed property to get the current list from ListManager
    private var list: Listy? {
        listManager.lists.first(where: { $0.id == listId })
    }

    // Check if current user is the creator of the list
    private var isCreator: Bool {
        list?.creatorId == listManager.userId
    }

    private var isValidInput: Bool {
        if case .success = InputValidator.validateItemName(newItem) {
            return true
        }
        return false
    }

    var body: some View {
        ZStack {
            // Main content
            mainContent
                .zIndex(0)

            // Onboarding overlay
            if showListDetailsOnboarding {
                ListDetailsOnboarding {
                    showListDetailsOnboarding = false
                }
                .transition(.opacity)
                .zIndex(999)
            }
        }
        .navigationBarBackButtonHidden(showListDetailsOnboarding)
        .toolbar(showListDetailsOnboarding ? .hidden : .visible, for: .tabBar)
        .onAppear {
            loadCollapsedStateIfNeeded()
            if !hasSeenListDetailsOnboarding {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showListDetailsOnboarding = true
                    }
                }
            }
        }
        .onChange(of: collapsedHeaderIds) { _ in
            guard didLoadCollapsedState else { return }
            saveCollapsedState()
        }
        .onChange(of: itemsSignature) { _ in
            loadCollapsedStateIfNeeded()
            pruneCollapsedHeaderIdsIfNeeded()
        }
    }

    private var mainContent: some View {
        ZStack {
            if list?.items.isEmpty ?? true {
                // Empty state
                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 20) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color("purple").opacity(0.1))
                                .frame(width: 100, height: 100)

                            Image("pin")
                                .resizable()
                                .renderingMode(.original)
                                .interpolation(.high)
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 50)
                        }

                        // Text content
                        VStack(spacing: 8) {
                            Text("Your list is empty")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.primary)

                            Text("Add items using the field below")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()
                    Spacer()
                }
            } else {
                List {
                    ForEach(list?.items ?? []) { item in
                        Group {
                            if visibleItemIds.contains(item.id) {
                                ItemView(
                                    item: item,
                                    listId: listId,
                                    isHeaderCollapsed: collapsedHeaderIds.contains(item.id),
                                    isSectionCollapseDisabled: isReordering || !headerHasChildren(item),
                                    onToggleKind: { tappedItem in
                                        toggleItemKind(tappedItem)
                                    },
                                    onToggleCollapse: { tappedItem in
                                        toggleHeaderCollapse(tappedItem)
                                    },
                                    editingItemId: editingItemId,
                                    editingText: $editingText,
                                    isEditInteractionDisabled: isSavingEdit || (editingItemId != nil && editingItemId != item.id),
                                    onStartEditing: { tappedItem in
                                        startEditing(tappedItem)
                                    },
                                    onSaveEditing: {
                                        saveEditingIfNeeded()
                                    },
                                    focusedField: $focusedField
                                )
                            }
                        }
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
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 80)
                }
            }

            List {}
                .preferredColorScheme(.light)
                .navigationBarTitleDisplayMode(.inline)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 80)
                }
                .opacity(0)

            // Bottom section with liquid glass background - overlaid on top
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    Group {
                        if editingItemId != nil {
                            Button(
                                action: {
                                    saveEditingIfNeeded()
                                },
                                label: {
                                    HStack(spacing: 10) {
                                        if isSavingEdit {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        }
                                        Text(isSavingEdit ? "Saving" : "Save")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        Color("purple"), in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    )
                                }
                            )
                            .disabled(isSavingEdit || editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .opacity((isSavingEdit || editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1.0)
                            .modifier(GlassEffectIfAvailable())
                            .padding(.horizontal)
                        } else {
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
                                        let item = Item(
                                            id: UUID().uuidString, text: newItem, order: currentList.items.count
                                        )
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
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
            }
            .zIndex(showListDetailsOnboarding ? -1 : 1)
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
            if !showListDetailsOnboarding {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(
                        content: {
                            if isCreator {
                                Button(
                                    action: {
                                        showListSettings = true
                                    },
                                    label: {
                                        Image(systemName: "slider.horizontal.3")
                                        Text("Settings")
                                    }
                                )

                                Divider()
                            }

                            Button(
                                action: {
                                    guard let joinCode = list?.joinCode else {
                                        AppLogger.ui.error("Cannot share: list has no joinCode")
                                        return
                                    }

                                    if let shareURL = DeepLinkHandler.generateShareURL(for: joinCode) {
                                        let listName = list?.name ?? "Untitled"
                                        let message = "Join my list '\(listName)' on Dash! Use code: \(joinCode)"
                                        let activityVC = UIActivityViewController(
                                            activityItems: [message, shareURL], applicationActivities: nil
                                        )
                                        if let windowScene = UIApplication.shared.connectedScenes.first
                                            as? UIWindowScene,
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
                                    listManager.removeCompletedItems(listId: listId)
                                },
                                label: {
                                    Image(systemName: "checkmark.circle.badge.xmark")
                                    Text("Remove Completed")
                                }
                            )
                            .disabled(!(list?.items.contains(where: { $0.done }) ?? false))

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

                            if isCreator {
                                Button(
                                    action: {
                                        showDeleteConfirmation = true
                                    },
                                    label: {
                                        Image(systemName: "trash")
                                        Text("Delete List")
                                    }
                                )
                            } else {
                                Button(
                                    action: {
                                        showLeaveConfirmation = true
                                    },
                                    label: {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                        Text("Leave List")
                                    }
                                )
                            }
                        },
                        label: {
                            Image(systemName: "gearshape.fill")
                        }
                    )
                }
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
            Text(
                "This will permanently delete all \(list?.items.count ?? 0) items from this list. This action cannot be undone."
            )
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
            Text(
                "This will permanently delete the list '\(list?.name ?? "Untitled")' and all its items. This action cannot be undone."
            )
        }
        .confirmationDialog(
            "Leave List",
            isPresented: $showLeaveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Leave List", role: .destructive) {
                listManager.leaveList(listId: listId)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "Are you sure you want to leave '\(list?.name ?? "Untitled")'? You'll need to be re-invited to join again."
            )
        }
        .sheet(isPresented: $showListSettings) {
            if let list = list {
                ListSettingsView(
                    listId: listId,
                    currentName: list.name,
                    currentEmoji: list.emoji,
                    currentColor: list.color
                )
                .environmentObject(listManager)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private func startEditing(_ item: Item) {
        guard !isSavingEdit else { return }
        guard editingItemId == nil else { return }
        editingItemId = item.id
        editingText = item.text
        focusedField = .editItem(item.id)
    }

    private func saveEditingIfNeeded() {
        guard let itemId = editingItemId else { return }
        let trimmed = editingText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !isSavingEdit else { return }

        focusedField = nil
        isSavingEdit = true
        listManager.updateItemText(listId: listId, itemId: itemId, newText: trimmed) { _ in
            DispatchQueue.main.async {
                self.isSavingEdit = false
                self.editingItemId = nil
                self.editingText = ""
            }
        }
    }
}

private extension ListDetailsView {
    var isReordering: Bool {
        editMode?.wrappedValue == .active
    }

    var visibleItemIds: Set<String> {
        guard !isReordering else {
            return Set(list?.items.map { $0.id } ?? [])
        }

        var visible = Set<String>()
        var isCollapsed = false
        for item in list?.items ?? [] {
            if item.kind == .header {
                isCollapsed = collapsedHeaderIds.contains(item.id)
                visible.insert(item.id)
            } else {
                if !isCollapsed {
                    visible.insert(item.id)
                }
            }
        }
        return visible
    }

    var collapsedStorageKey: String {
        "collapsedHeaderIds.\(listId)"
    }

    var itemsSignature: String {
        (list?.items ?? []).map { "\($0.id):\($0.kind.rawValue)" }.joined(separator: "|")
    }

    func loadCollapsedStateIfNeeded() {
        guard !didLoadCollapsedState else { return }
        let stored = UserDefaults.standard.array(forKey: collapsedStorageKey) as? [String] ?? []
        collapsedHeaderIds = Set(stored)
        didLoadCollapsedState = true
        pruneCollapsedHeaderIdsIfNeeded()
    }

    func saveCollapsedState() {
        UserDefaults.standard.set(Array(collapsedHeaderIds), forKey: collapsedStorageKey)
    }

    func pruneCollapsedHeaderIdsIfNeeded() {
        let validHeaderIds = Set((list?.items ?? []).filter { $0.kind == .header }.map { $0.id })
        let pruned = collapsedHeaderIds.intersection(validHeaderIds)
        if pruned != collapsedHeaderIds {
            collapsedHeaderIds = pruned
        }
    }

    func headerHasChildren(_ header: Item) -> Bool {
        guard header.kind == .header else { return false }
        guard let items = list?.items, let headerIndex = items.firstIndex(where: { $0.id == header.id }) else { return false }

        let nextIndex = items.index(after: headerIndex)
        guard nextIndex < items.endIndex else { return false }
        for item in items[nextIndex...] {
            if item.kind == .header {
                return false
            }
            return true
        }
        return false
    }

    func toggleHeaderCollapse(_ header: Item) {
        guard header.kind == .header else { return }
        if collapsedHeaderIds.contains(header.id) {
            collapsedHeaderIds.remove(header.id)
        } else {
            collapsedHeaderIds.insert(header.id)
        }
    }

    func toggleItemKind(_ item: Item) {
        guard !isSavingEdit else { return }
        guard editingItemId == nil || editingItemId == item.id else { return }

        let newKind: Item.Kind = (item.kind == .header) ? .task : .header
        if newKind == .task {
            collapsedHeaderIds.remove(item.id)
        }

        listManager.updateItemKind(listId: listId, itemId: item.id, kind: newKind)
    }
}

struct ListDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ListDetailsView(listId: "2")
            .environmentObject(ListManager(userId: "asd"))
    }
}
