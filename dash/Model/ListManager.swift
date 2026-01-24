//
//  ListManager.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 27.
//

import FirebaseCore
import FirebaseFirestore
import Foundation
import OSLog

/// Manages list data and operations with Firebase Firestore
class ListManager: ObservableObject {
    var userId: String

    private let firestore = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var itemListeners: [String: ListenerRegistration] = [:]

    @Published var lists: [Listy] = []
    @Published var currentListIndex = 0
    @Published var isLoading: Bool = true
    @Published var hasLoadedInitialLists: Bool = false

    init(userId: String) {
        self.userId = userId
        AppLogger.database.info("ListManager initialized")
        Task {
            await fetchLists()
        }
    }

    func updateItemKind(listId: String, itemId: String, kind: Item.Kind, completion: ((Error?) -> Void)? = nil) {
        let itemRef = firestore.collection("lists").document(listId)
            .collection("items").document(itemId)

        var data: [String: Any] = [
            "kind": kind.rawValue,
        ]

        if kind == .header {
            data["done"] = false
        }

        itemRef.updateData(data) { error in
            if let error = error {
                AppLogger.database.error("Failed to update item kind: \(error.localizedDescription)")
                completion?(error)
            } else {
                AppLogger.database.debug("Item kind updated")
                completion?(nil)
            }
        }
    }

    deinit {
        AppLogger.database.debug("ListManager deallocated, removing listeners")
        listenerRegistration?.remove()
        itemListeners.values.forEach { $0.remove() }
    }
}

extension ListManager {
    func fetchLists() async {
        AppLogger.database.info("Setting up lists listener")
        listenerRegistration?.remove()

        DispatchQueue.main.async {
            self.isLoading = true
            self.hasLoadedInitialLists = false
        }

        listenerRegistration = firestore.collection("lists").whereField("users", arrayContains: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }

                guard let snapshot = querySnapshot else {
                    if let error = error {
                        AppLogger.database.error("Failed to fetch lists: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        self.hasLoadedInitialLists = true
                        self.isLoading = false
                    }
                    return
                }

                DispatchQueue.main.async {
                    // Process only document changes instead of rebuilding entire list
                    for diff in snapshot.documentChanges {
                        let data = diff.document.data()
                        let documentID = diff.document.documentID

                        switch diff.type {
                        case .added:
                            // Parse and add new list (without items)
                            let list = self.parseList(documentID: documentID, data: data)
                            self.lists.append(list)
                            AppLogger.database.notice("List added: \(list.name, privacy: .public)")
                            AppLogger.database.debug("List members: \(list.users.count)")
                            // Start listening to items subcollection
                            self.listenToItems(for: documentID)

                        case .modified:
                            // Update existing list metadata (preserve items)
                            if let index = self.lists.firstIndex(where: { $0.id == documentID }) {
                                let name = data["name"] as? String ?? ""
                                let emoji = data["emoji"] as? String
                                let color = data["color"] as? String
                                let users = data["users"] as? [String] ?? []
                                let creatorId = data["creatorId"] as? String
                                self.lists[index].name = name
                                self.lists[index].emoji = emoji
                                self.lists[index].color = color
                                self.lists[index].users = users
                                self.lists[index].creatorId = creatorId
                                AppLogger.database.info("List modified: \(name, privacy: .public)")
                            }

                        case .removed:
                            // Remove list and stop listening to items
                            self.itemListeners[documentID]?.remove()
                            self.itemListeners.removeValue(forKey: documentID)
                            self.lists.removeAll(where: { $0.id == documentID })
                            AppLogger.database.notice("List removed")
                        }
                    }

                    if !self.hasLoadedInitialLists {
                        self.hasLoadedInitialLists = true
                        self.isLoading = false
                    }
                }
            }
    }

    /// Parses Firestore document data into a Listy object (without items)
    private func parseList(documentID: String, data: [String: Any]) -> Listy {
        let name = data["name"] as? String ?? ""
        let emoji = data["emoji"] as? String
        let color = data["color"] as? String
        let users = data["users"] as? [String] ?? []
        let creatorId = data["creatorId"] as? String
        let joinCode = data["joinCode"] as? String
        // Items will be populated by the items subcollection listener
        return Listy(id: documentID, name: name, emoji: emoji, color: color, items: [], users: users, creatorId: creatorId, joinCode: joinCode)
    }

    /// Sets up a listener for items in a specific list
    private func listenToItems(for listId: String) {
        // Prevent duplicate listeners
        if itemListeners[listId] != nil {
            AppLogger.database.debug("Items listener already exists for list")
            return
        }

        AppLogger.database.debug("Setting up items listener for list")
        let itemsRef = firestore.collection("lists").document(listId).collection("items")

        let listener = itemsRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }

            guard let snapshot = querySnapshot else {
                if let error = error {
                    AppLogger.database.error("Failed to fetch items: \(error.localizedDescription)")
                }
                return
            }

            guard let listIndex = self.lists.firstIndex(where: { $0.id == listId }) else {
                return
            }

            // Process item changes
            for diff in snapshot.documentChanges {
                let data = diff.document.data()
                let itemId = diff.document.documentID

                switch diff.type {
                case .added:
                    let item = self.parseItem(itemId: itemId, data: data)
                    self.lists[listIndex].items.append(item)

                case .modified:
                    if let itemIndex = self.lists[listIndex].items.firstIndex(where: { $0.id == itemId }) {
                        let item = self.parseItem(itemId: itemId, data: data)
                        self.lists[listIndex].items[itemIndex] = item
                    }

                case .removed:
                    self.lists[listIndex].items.removeAll(where: { $0.id == itemId })
                }
            }

            // Keep items sorted
            self.lists[listIndex].items.sort(by: { $0.order < $1.order })
        }

        itemListeners[listId] = listener
    }

    /// Parses item document data into an Item object
    private func parseItem(itemId: String, data: [String: Any]) -> Item {
        let text = data["text"] as? String ?? ""
        let done = data["done"] as? Bool ?? false
        let order = data["order"] as? Int ?? 0
        let kindRawValue = data["kind"] as? String
        let kind = Item.Kind(rawValue: kindRawValue ?? Item.Kind.task.rawValue) ?? .task
        return Item(id: itemId, text: text, done: done, order: order, kind: kind)
    }

    /// Generates a unique 8-character alphanumeric join code
    private func generateJoinCode() -> String {
        let characters = "abcdefghjkmnpqrstuvwxyz23456789" // Excluded similar chars: i,l,o,0,1
        return String((0 ..< 8).map { _ in characters.randomElement()! })
    }

    func createList(listName: String, emoji: String? = nil, color: String? = nil, completion: @escaping (Bool, String) -> Void) {
        let uid = UUID().uuidString
        let joinCode = generateJoinCode()

        var data: [String: Any] = [
            "name": listName,
            "users": [userId],
            "creatorId": userId,
            "joinCode": joinCode,
        ]
        if let emoji = emoji {
            data["emoji"] = emoji
        }
        if let color = color {
            data["color"] = color
        }

        AppLogger.database.info("Creating list with joinCode: \(joinCode)")

        // Optimistically succeed immediately since we have offline persistence
        // Firestore will sync when online
        completion(true, "")

        firestore.collection("lists").document(uid).setData(data) { err in
            if let err = err {
                AppLogger.network.error("Create list sync error: \(err.localizedDescription)")
            } else {
                AppLogger.network.info("List synced to server with joinCode: \(joinCode)")
            }
        }
    }

    func updateList(listId: String, listName: String, emoji: String?, color: String?, completion: @escaping (Bool, String) -> Void) {
        var data: [String: Any] = [
            "name": listName,
        ]

        // Update emoji (or remove if nil)
        if let emoji = emoji {
            data["emoji"] = emoji
        } else {
            data["emoji"] = FieldValue.delete()
        }

        // Update color (or remove if nil)
        if let color = color {
            data["color"] = color
        } else {
            data["color"] = FieldValue.delete()
        }

        // Optimistically succeed immediately since we have offline persistence
        // Firestore will sync when online
        completion(true, "")

        firestore.collection("lists").document(listId).updateData(data) { err in
            if let err = err {
                AppLogger.network.error("Update list sync error: \(err.localizedDescription)")
            } else {
                AppLogger.network.info("List update synced to server")
            }
        }
    }

    func joinToList(joinCode: String, userId: String, completion: @escaping (Bool, String) -> Void) {
        AppLogger.database.info("Attempting to join list with code: \(joinCode)")

        // Query for list by joinCode
        firestore.collection("lists")
            .whereField("joinCode", isEqualTo: joinCode)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    AppLogger.database.error("Error fetching list: \(error.localizedDescription)")
                    completion(false, "Connection error. Please check your internet and try again.")
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    AppLogger.database.warning("List does not exist for joinCode: \(joinCode)")
                    completion(false, "This join code is invalid or the list has been deleted.")
                    return
                }

                let document = documents[0]
                let listId = document.documentID

                // Check if user already has this list
                if self.lists.contains(where: { $0.id == listId }) {
                    AppLogger.database.info("User already a member of list: \(listId)")
                    completion(false, "You're already a member of this list! 🎉")
                    return
                }

                guard let data = document.data() as? [String: Any] else {
                    AppLogger.database.error("Failed to parse list data")
                    completion(false, "Something went wrong. Please try again.")
                    return
                }

                // Get list name for better message
                let listName = data["name"] as? String ?? "the list"
                let listEmoji = data["emoji"] as? String
                let displayName = listEmoji != nil ? "\(listEmoji!) \(listName)" : listName

                var users = data["users"] as? [String] ?? []
                users.append(userId)

                document.reference.updateData(["users": users]) { updateError in
                    if let updateError = updateError {
                        AppLogger.database.error("Failed to join list: \(updateError.localizedDescription)")
                        completion(false, "Failed to join the list. Please try again.")
                    } else {
                        AppLogger.database.notice("User successfully joined list: \(listName)")
                        completion(true, "You've joined \"\(displayName)\"! 🎉")
                    }
                }
            }
    }

    func addItemToList(listId: String, item: Item) {
        let itemRef = firestore.collection("lists").document(listId)
            .collection("items").document(item.id)

        if item.kind == .task {
            let cached = UserManager.getCachedTotalItemsCreated(userId: userId)
            UserManager.cacheTotalItemsCreated(cached + 1, userId: userId)
        }

        itemRef.setData([
            "text": item.text,
            "done": item.done,
            "order": item.order,
            "kind": item.kind.rawValue,
        ]) { err in
            if let err = err {
                AppLogger.database.error("Failed to add item: \(err.localizedDescription)")
            } else {
                AppLogger.database.notice("Item added")
                if item.kind == .task {
                    UserManager(userId: self.userId).incrementItemCountRemoteOnly()
                }
            }
        }
    }

    // MARK: - User-related functions (delegated to UserManager)

    func incrementUserItemCount() {
        let userManager = UserManager(userId: userId)
        userManager.incrementItemCount()
    }

    func fetchUserItemCount(completion: @escaping (Int) -> Void) {
        let userManager = UserManager(userId: userId)
        userManager.fetchUserItemCount(completion: completion)
    }

    func fetchUserFirstName(completion: @escaping (String) -> Void) {
        let userManager = UserManager(userId: userId)
        userManager.fetchUserFirstName(completion: completion)
    }

    func setSelectedList(listId: String) {
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            currentListIndex = index
        }
    }

    func deleteList(listId: String) {
        // First, get all items to delete from subcollection
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }) else { return }
        let items = lists[listIndex].items

        // Remove from local state immediately
        lists = lists.filter { $0.id != listId }

        // Delete all items in subcollection first
        let batch = firestore.batch()

        for item in items {
            let itemRef = firestore.collection("lists").document(listId)
                .collection("items").document(item.id)
            batch.deleteDocument(itemRef)
        }

        // Commit item deletions first
        batch.commit { error in
            if let error = error {
                AppLogger.database.error("Failed to delete items: \(error.localizedDescription)")
            } else {
                AppLogger.database.info("All items deleted, deleting list document")

                // Now delete the list document itself
                self.firestore.collection("lists").document(listId).delete { err in
                    if let err = err {
                        AppLogger.database.error("Failed to remove list document: \(err.localizedDescription)")
                    } else {
                        AppLogger.database.notice("List document removed")
                    }
                }
            }
        }
    }

    func leaveList(listId: String) {
        let docRef = firestore.collection("lists").document(listId)
        docRef.getDocument { document, _ in
            if let document = document, document.exists {
                let data = document.data()
                if let data = data {
                    var users = data["users"] as? [String] ?? []
                    users.removeAll { $0 == self.userId }

                    docRef.updateData([
                        "users": users,
                    ]) { err in
                        if let err = err {
                            AppLogger.database.error("Failed to leave list: \(err.localizedDescription)")
                        } else {
                            AppLogger.database.notice("User left list")
                        }
                    }
                }
            } else {
                AppLogger.database.warning("List not found")
            }
        }
    }

    func doneItemInList(listId: String, itemId: String) {
        let itemRef = firestore.collection("lists").document(listId)
            .collection("items").document(itemId)

        itemRef.updateData([
            "done": true,
        ]) { error in
            if let error = error {
                AppLogger.database.error("Failed to mark item as done: \(error.localizedDescription)")
            } else {
                AppLogger.database.debug("Item marked as done")
            }
        }
    }

    func unDoneItemInList(listId: String, itemId: String) {
        let itemRef = firestore.collection("lists").document(listId)
            .collection("items").document(itemId)

        itemRef.updateData([
            "done": false,
        ]) { error in
            if let error = error {
                AppLogger.database.error("Failed to mark item as undone: \(error.localizedDescription)")
            } else {
                AppLogger.database.debug("Item marked as undone")
            }
        }
    }

    func updateItemText(listId: String, itemId: String, newText: String, completion: ((Error?) -> Void)? = nil) {
        let itemRef = firestore.collection("lists").document(listId)
            .collection("items").document(itemId)

        itemRef.updateData([
            "text": newText,
        ]) { error in
            if let error = error {
                AppLogger.database.error("Failed to update item text: \(error.localizedDescription)")
                completion?(error)
            } else {
                AppLogger.database.debug("Item text updated")
                completion?(nil)
            }
        }
    }

    func deleteItemFromList(listId: String, itemId: String) {
        let itemRef = firestore.collection("lists").document(listId)
            .collection("items").document(itemId)

        itemRef.delete { err in
            if let err = err {
                AppLogger.database.error("Failed to delete item: \(err.localizedDescription)")
            } else {
                AppLogger.database.info("Item deleted")
            }
        }
    }

    func updateItemOrder(listId: String, itemId: String, newOrder: Int) {
        let itemRef = firestore.collection("lists").document(listId)
            .collection("items").document(itemId)

        itemRef.updateData([
            "order": newOrder,
        ]) { err in
            if let err = err {
                AppLogger.database.error("Failed to update item order: \(err.localizedDescription)")
            } else {
                AppLogger.database.debug("Item order updated")
            }
        }
    }

    func updateMultipleItemOrders(listId: String, items: [(itemId: String, order: Int)]) {
        let batch = firestore.batch()

        for item in items {
            let itemRef = firestore.collection("lists").document(listId)
                .collection("items").document(item.itemId)
            batch.updateData(["order": item.order], forDocument: itemRef)
        }

        batch.commit { error in
            if let error = error {
                AppLogger.database.error("Failed to update item orders: \(error.localizedDescription)")
            } else {
                AppLogger.database.info("Batch item orders updated")
            }
        }
    }

    func markAllItemsAsDone(listId: String) {
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }) else { return }
        let items = lists[listIndex].items.filter { $0.kind == .task }

        let batch = firestore.batch()

        for item in items {
            let itemRef = firestore.collection("lists").document(listId)
                .collection("items").document(item.id)
            batch.updateData(["done": true], forDocument: itemRef)
        }

        batch.commit { error in
            if let error = error {
                AppLogger.database.error("Failed to mark all items as done: \(error.localizedDescription)")
            } else {
                AppLogger.database.notice("All items marked as done")
            }
        }
    }

    func markAllItemsAsUndone(listId: String) {
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }) else { return }
        let items = lists[listIndex].items.filter { $0.kind == .task }

        let batch = firestore.batch()

        for item in items {
            let itemRef = firestore.collection("lists").document(listId)
                .collection("items").document(item.id)
            batch.updateData(["done": false], forDocument: itemRef)
        }

        batch.commit { error in
            if let error = error {
                AppLogger.database.error("Failed to mark all items as undone: \(error.localizedDescription)")
            } else {
                AppLogger.database.notice("All items marked as undone")
            }
        }
    }

    func clearAllItems(listId: String) {
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }) else { return }
        let items = lists[listIndex].items

        let batch = firestore.batch()

        for item in items {
            let itemRef = firestore.collection("lists").document(listId)
                .collection("items").document(item.id)
            batch.deleteDocument(itemRef)
        }

        batch.commit { error in
            if let error = error {
                AppLogger.database.error("Failed to clear all items: \(error.localizedDescription)")
            } else {
                AppLogger.database.notice("All items cleared")
            }
        }
    }

    func removeCompletedItems(listId: String) {
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }) else { return }
        let completedItems = lists[listIndex].items.filter { $0.done }

        guard !completedItems.isEmpty else { return }

        let batch = firestore.batch()

        for item in completedItems {
            let itemRef = firestore.collection("lists").document(listId)
                .collection("items").document(item.id)
            batch.deleteDocument(itemRef)
        }

        batch.commit { error in
            if let error = error {
                AppLogger.database.error("Failed to remove completed items: \(error.localizedDescription)")
            } else {
                AppLogger.database.notice("Completed items removed")
            }
        }
    }

    func deleteAllUserLists(completion: @escaping (Error?) -> Void) {
        firestore.collection("lists")
            .whereField("users", arrayContains: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    AppLogger.database.error("Failed to fetch user lists: \(error.localizedDescription)")
                    completion(error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(nil)
                    return
                }

                let dispatchGroup = DispatchGroup()
                var deletionError: Error?

                for document in documents {
                    let data = document.data()
                    let listRef = document.reference
                    let creatorId = data["creatorId"] as? String

                    dispatchGroup.enter()

                    if creatorId == self.userId {
                        // User is the creator - delete the entire list and all items
                        AppLogger.database.info("Deleting owned list: \(document.documentID)")

                        // First, delete all items
                        listRef.collection("items").getDocuments { itemsSnapshot, itemsError in
                            if let itemsError = itemsError {
                                AppLogger.database.error("Failed to fetch items for deletion: \(itemsError.localizedDescription)")
                            }

                            let itemBatch = self.firestore.batch()
                            if let items = itemsSnapshot?.documents {
                                for item in items {
                                    itemBatch.deleteDocument(item.reference)
                                }
                            }

                            // Commit item deletions
                            itemBatch.commit { itemDeleteError in
                                if let itemDeleteError = itemDeleteError {
                                    AppLogger.database.error("Failed to delete items: \(itemDeleteError.localizedDescription)")
                                    deletionError = itemDeleteError
                                }

                                // Then delete the list itself
                                listRef.delete { listDeleteError in
                                    if let listDeleteError = listDeleteError {
                                        AppLogger.database.error("Failed to delete list: \(listDeleteError.localizedDescription)")
                                        deletionError = listDeleteError
                                    } else {
                                        AppLogger.database.notice("Deleted owned list and its items")
                                    }
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    } else {
                        // User is NOT the creator - just remove user from the list
                        AppLogger.database.info("Leaving shared list: \(document.documentID)")

                        var users = data["users"] as? [String] ?? []
                        users.removeAll { $0 == self.userId }

                        listRef.updateData(["users": users]) { updateError in
                            if let updateError = updateError {
                                AppLogger.database.error("Failed to leave list: \(updateError.localizedDescription)")
                                deletionError = updateError
                            } else {
                                AppLogger.database.notice("Left shared list")
                            }
                            dispatchGroup.leave()
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    if let error = deletionError {
                        completion(error)
                    } else {
                        AppLogger.database.notice("Account cleanup completed: owned lists deleted, shared lists left")
                        completion(nil)
                    }
                }
            }
    }
}
