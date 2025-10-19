//
//  ListManager.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 27.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

/// Manages list data and operations with Firebase Firestore
class ListManager: ObservableObject {
    var userId: String

    private let firestore = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var itemListeners: [String: ListenerRegistration] = [:]

    @Published var lists: [Listy] = []
    @Published var currentListIndex = 0
    @Published var isLoading: Bool = true

    init(userId: String) {
        self.userId = userId
        Task {
            await fetchLists()
        }
    }

    deinit {
        listenerRegistration?.remove()
        itemListeners.values.forEach { $0.remove() }
    }

    func fetchLists() async {
        listenerRegistration?.remove()

        listenerRegistration = firestore.collection("lists").whereField("users", arrayContains: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }

                guard let snapshot = querySnapshot else {
                    if let error = error {
                        print("Error fetching documents: \(error.localizedDescription)")
                    }
                    return
                }

                // Process only document changes instead of rebuilding entire list
                for diff in snapshot.documentChanges {
                    let data = diff.document.data()
                    let documentID = diff.document.documentID

                    switch diff.type {
                    case .added:
                        // Parse and add new list (without items)
                        let list = self.parseList(documentID: documentID, data: data)
                        self.lists.append(list)
                        print("Added list: \(list.name)")
                        // Start listening to items subcollection
                        self.listenToItems(for: documentID)

                    case .modified:
                        // Update existing list metadata (preserve items)
                        if let index = self.lists.firstIndex(where: { $0.id == documentID }) {
                            let name = data["name"] as? String ?? ""
                            let emoji = data["emoji"] as? String
                            let users = data["users"] as? [String] ?? []
                            self.lists[index].name = name
                            self.lists[index].emoji = emoji
                            self.lists[index].users = users
                            print("Modified list: \(name)")
                        }

                    case .removed:
                        // Remove list and stop listening to items
                        self.itemListeners[documentID]?.remove()
                        self.itemListeners.removeValue(forKey: documentID)
                        self.lists.removeAll(where: { $0.id == documentID })
                        print("Removed list: \(documentID)")
                    }
                }
            }
        isLoading = false
    }

    /// Parses Firestore document data into a Listy object (without items)
    private func parseList(documentID: String, data: [String: Any]) -> Listy {
        let name = data["name"] as? String ?? ""
        let emoji = data["emoji"] as? String
        let users = data["users"] as? [String] ?? []
        // Items will be populated by the items subcollection listener
        return Listy(id: documentID, name: name, emoji: emoji, items: [], users: users)
    }

    /// Sets up a listener for items in a specific list
    private func listenToItems(for listId: String) {
        // Prevent duplicate listeners
        if itemListeners[listId] != nil {
            return
        }

        let itemsRef = firestore.collection("lists").document(listId).collection("items")

        let listener = itemsRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }

            guard let snapshot = querySnapshot else {
                if let error = error {
                    print("Error fetching items: \(error.localizedDescription)")
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
        return Item(id: itemId, text: text, done: done, order: order)
    }

    func createList(listName: String, emoji: String? = nil, completion: @escaping (String) -> Void) {
        let uid = UUID().uuidString
        var data: [String: Any] = [
            "name": listName,
            "users": [userId],
        ]
        if let emoji = emoji {
            data["emoji"] = emoji
        }
        firestore.collection("lists").document(uid).setData(data) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion("Failed to create new list, please check your internet connection or try again!")
                return
            } else {
                print("Document successfully written!")
                completion("List successfully created!")
            }
        }
    }

    func joinToList(listId: String, userId: String, completion: @escaping (String) -> Void) {
        if lists.contains(where: { $0.id == listId }) {
            completion("Your profile already have this list.")
            return
        }
        let docRef = firestore.collection("lists").document(listId)
        docRef.getDocument { document, _ in
            if let document = document, document.exists {
                let data = document.data()
                if let data {
                    var users = data["users"] as? [String] ?? []
                    users.append(userId)

                    docRef.updateData([
                        "users": users,
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                            completion("Failed to join, check your internet connection or try again!")
                        } else {
                            print("Document successfully updated!")
                            completion("Successfully joined the list!")
                        }
                    }
                }
            } else {
                print("Document does not exist")
                completion("This list does not exist!")
            }
        }
    }

    func addItemToList(listId: String, item: Item) {
        let itemRef = firestore.collection("lists").document(listId)
            .collection("items").document(item.id)

        itemRef.setData([
            "text": item.text,
            "done": item.done,
            "order": item.order,
        ]) { err in
            if let err = err {
                print("Error adding item: \(err)")
            } else {
                print("Item successfully added!")
            }
        }
    }

    func setSelectedList(listId: String) {
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            currentListIndex = index
        }
    }

    func deleteList(listId: String) {
        lists = lists.filter { $0.id != listId }
        firestore.collection("lists").document(listId).delete { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
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
                print("Error marking item as done: \(error)")
            } else {
                print("Item marked as done!")
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
                print("Error marking item as undone: \(error)")
            } else {
                print("Item marked as undone!")
            }
        }
    }

    func deleteItemFromList(listId: String, itemId: String) {
        let itemRef = firestore.collection("lists").document(listId)
            .collection("items").document(itemId)

        itemRef.delete { err in
            if let err = err {
                print("Error deleting item: \(err)")
            } else {
                print("Item successfully deleted!")
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
                print("Error updating item order: \(err)")
            } else {
                print("Item order updated!")
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
                print("Error updating item orders: \(error)")
            } else {
                print("All item orders updated in batch!")
            }
        }
    }
}
