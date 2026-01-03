//
//  HomeView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 18.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var listManager: ListManager
    @State private var firstName: String = ""
    @State private var activeListId: String?
    @State private var isEditing: Bool = false
    @State private var draggingListId: String?
    @State private var dragTranslation: CGSize = .zero
    @State private var dragOriginIndex: Int?
    @State private var dragCurrentIndex: Int?
    @State private var dragStartLocationY: CGFloat?
    @State private var localListOrder: [String] = []
    @Binding var selectedTab: Int

    private let listButtonHeight: CGFloat = 100
    private let listButtonSpacing: CGFloat = 16
    private var listButtonStride: CGFloat {
        listButtonHeight + listButtonSpacing
    }

    private func rowYOffset(for listId: String) -> CGFloat {
        guard let draggingListId,
              let originIndex = dragOriginIndex,
              let currentIndex = dragCurrentIndex
        else {
            return 0
        }

        if listId == draggingListId {
            return dragTranslation.height
        }

        guard let myIndex = localListOrder.firstIndex(of: listId) else {
            return 0
        }

        if originIndex < currentIndex {
            if myIndex > originIndex, myIndex <= currentIndex {
                return -listButtonStride
            }
        } else if originIndex > currentIndex {
            if myIndex >= currentIndex, myIndex < originIndex {
                return listButtonStride
            }
        }

        return 0
    }

    private var listOrderKey: String {
        "home_list_order_\(listManager.userId)"
    }

    private var orderedLists: [Listy] {
        guard !localListOrder.isEmpty else {
            return listManager.lists
        }

        let byId = Dictionary(uniqueKeysWithValues: listManager.lists.map { ($0.id, $0) })
        var result: [Listy] = []
        result.reserveCapacity(listManager.lists.count)

        for id in localListOrder {
            if let list = byId[id] {
                result.append(list)
            }
        }

        for list in listManager.lists where !localListOrder.contains(list.id) {
            result.append(list)
        }
        return result
    }

    var body: some View {
        NavigationView {
            ScrollView {
                if listManager.lists.isEmpty {
                    EmptyStateView(onCreateList: {
                        selectedTab = 1
                    })
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(orderedLists) { list in
                            Group {
                                if isEditing {
                                    ListButton(
                                        text: list.name,
                                        emoji: list.emoji,
                                        color: list.color,
                                        allItems: list.items.count,
                                        completedItems: list.items.filter { $0.done }.count,
                                        sharedWith: list.users.count,
                                        isEditing: true,
                                        onGripDragChanged: { value in
                                            handleGripDragChanged(listId: list.id, value: value)
                                        },
                                        onGripDragEnded: { _ in
                                            handleGripDragEnded()
                                        }
                                    )
                                } else {
                                    NavigationLink(
                                        tag: list.id,
                                        selection: $activeListId,
                                        destination: {
                                            ListDetailsView(listId: list.id)
                                        },
                                        label: {
                                            ListButton(
                                                text: list.name,
                                                emoji: list.emoji,
                                                color: list.color,
                                                allItems: list.items.count,
                                                completedItems: list.items.filter { $0.done }.count,
                                                sharedWith: list.users.count
                                            )
                                        }
                                    )
                                    .buttonStyle(.plain)
                                    .onTapGesture {
                                        listManager.setSelectedList(listId: list.id)
                                        activeListId = list.id
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .frame(height: listButtonHeight)
                            .offset(y: rowYOffset(for: list.id))
                            .zIndex(draggingListId == list.id ? 1 : 0)
                            .transaction { transaction in
                                if draggingListId != nil {
                                    transaction.animation = nil
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .scrollDisabled(draggingListId != nil)
            .navigationTitle(getGreeting())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("Your lists")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                        if !isEditing {
                            saveLocalOrder()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedTab = 1
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                // Load cached name immediately for instant display
                firstName = UserManager.getCachedFirstName()
                // Then fetch from Firestore to sync any updates
                loadUserName()
                activeListId = nil
                loadLocalOrderIfNeeded()
            }
            .onChange(of: listManager.lists.map { $0.id }) { _ in
                reconcileLocalOrder()
            }
        }
    }

    private func handleGripDragChanged(listId: String, value: DragGesture.Value) {
        if draggingListId == nil {
            draggingListId = listId
            dragOriginIndex = localListOrder.firstIndex(of: listId)
            dragCurrentIndex = dragOriginIndex
            dragStartLocationY = value.startLocation.y
        }

        guard draggingListId == listId else {
            return
        }

        if let startY = dragStartLocationY {
            dragTranslation = CGSize(width: 0, height: value.location.y - startY)
        } else {
            dragTranslation = value.translation
        }

        guard let originIndex = dragOriginIndex,
              localListOrder.firstIndex(of: listId) != nil
        else {
            return
        }

        let hysteresis: CGFloat = 0.35
        let translation = dragTranslation.height
        let adjusted = translation >= 0
            ? translation + listButtonStride * hysteresis
            : translation - listButtonStride * hysteresis
        let step = Int(adjusted / listButtonStride)
        let targetIndex = min(max(originIndex + step, 0), max(localListOrder.count - 1, 0))

        dragCurrentIndex = targetIndex
    }

    private func handleGripDragEnded() {
        if let originIndex = dragOriginIndex,
           let targetIndex = dragCurrentIndex,
           originIndex != targetIndex,
           originIndex < localListOrder.count
        {
            let moved = localListOrder.remove(at: originIndex)
            let insertIndex = min(max(targetIndex, 0), localListOrder.count)
            localListOrder.insert(moved, at: insertIndex)
        }

        draggingListId = nil
        dragTranslation = .zero
        dragOriginIndex = nil
        dragCurrentIndex = nil
        dragStartLocationY = nil
        saveLocalOrder()
    }

    private func loadLocalOrderIfNeeded() {
        guard localListOrder.isEmpty else {
            return
        }
        let decoded = loadLocalOrder()
        localListOrder = decoded
        reconcileLocalOrder()
    }

    private func reconcileLocalOrder() {
        let existingIds = Set(listManager.lists.map { $0.id })
        let filtered = localListOrder.filter { existingIds.contains($0) }
        let missing = listManager.lists.map { $0.id }.filter { !filtered.contains($0) }

        let reconciled = filtered + missing
        if reconciled != localListOrder {
            localListOrder = reconciled
            saveLocalOrder()
        }
    }

    private func loadLocalOrder() -> [String] {
        guard let data = UserDefaults.standard.data(forKey: listOrderKey) else {
            return []
        }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    private func saveLocalOrder() {
        guard let data = try? JSONEncoder().encode(localListOrder) else {
            return
        }
        UserDefaults.standard.set(data, forKey: listOrderKey)
    }

    func loadUserName() {
        listManager.fetchUserFirstName { name in
            firstName = name
        }
    }

    func getGreeting() -> String {
        if firstName.isEmpty {
            return "Hey! 👋"
        } else {
            return "Hey, \(firstName)! 👋"
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(0))
            .environmentObject(ListManager(userId: "asd"))
    }
}
