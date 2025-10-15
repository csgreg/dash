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

    @Published var lists: [Listy] = []
    @Published var currentListIndex = 0
    @Published var isLoading: Bool = true

    init(userId: String) {
        self.userId = userId
        Task {
            await fetchLists()
        }
    }

    func fetchLists() async {
        firestore.collection("lists").whereField("users", arrayContains: userId)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    if let error = error {
                        print("Error fetching documents: \(error.localizedDescription)")
                    }
                    return
                }
                var incomingLists: [Listy] = []
                for data in documents {
                    let name = data["name"]! as? String ?? ""
                    let users = data["users"]! as? [String] ?? []
                    var list = Listy(id: data.documentID, name: name, items: [], users: users)
                    let items = data["items"] as? NSArray as? [NSDictionary] as? [[String: Any]]
                    items?.forEach { item in
                        let text = item["text"] as? String ?? ""
                        let id = item["id"] as? String ?? ""
                        let done = item["done"] as? Bool ?? false
                        let order = item["order"] as? Int ?? 0
                        list.items.append(Item(id: id, text: text, done: done, order: order))
                    }
                    list.items = list.items.sorted(by: { $0.order < $1.order })
                    incomingLists.append(list)
                }
                self.lists = incomingLists
                print("firestore updated, lists:", self.lists)
            }
        isLoading = false
    }

    func createList(listName: String, completion: @escaping (String) -> Void) {
        let uid = UUID().uuidString
        firestore.collection("lists").document(uid).setData([
            "name": listName,
            "items": [],
            "users": [userId],
        ]) { err in
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
                    let id = document.documentID
                    let name = data["name"] as? String ?? ""
                    var users = data["users"] as? [String] ?? []
                    users.append(userId)
                    var list = Listy(id: id, name: name, items: [], users: users)
                    let items = data["items"] as? NSArray as? [NSDictionary] as? [[String: Any]]
                    items?.forEach { item in
                        let text = item["text"] as? String ?? ""
                        let id = item["id"] as? String ?? ""
                        let done = item["done"] as? Bool ?? false
                        let order = item["order"] as? Int ?? 0
                        list.items.append(Item(id: id, text: text, done: done, order: order))
                    }
                    self.lists.append(list)

                    docRef.updateData([
                        "users": users,
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                            completion("Failed to join, check your internet connection or try again!")
                        } else {
                            print("Document successfully updated!")
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
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            lists[index].items.append(item)
            let listRef = firestore.collection("lists").document(listId)

            listRef.updateData([
                "items": lists[index].items.map {
                    ["id": $0.id, "text": $0.text, "done": $0.done, "order": $0.order]
                },
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated!")
                }
            }
        }
    }

    func updateItemsInList(listId: String, items: [Item]) {
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            let listRef = firestore.collection("lists").document(listId)

            listRef.updateData([
                "items": items.map {
                    ["id": $0.id, "text": $0.text, "done": $0.done, "order": $0.order]
                },
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated!")
                }
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
        if let listIndex = lists.firstIndex(where: { $0.id == listId }) {
            if let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == itemId }) {
                // Mark as done
                lists[listIndex].items[itemIndex].done = true

                // Move to end: set order to max + 1
                let maxOrder = lists[listIndex].items.map { $0.order }.max() ?? 0
                lists[listIndex].items[itemIndex].order = maxOrder + 1

                // Re-sort items
                lists[listIndex].items.sort(by: { $0.order < $1.order })

                let listRef = firestore.collection("lists").document(listId)
                listRef.updateData([
                    "items": lists[listIndex].items.map {
                        ["id": $0.id, "text": $0.text, "done": $0.done, "order": $0.order]
                    },
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated!")
                    }
                }
            }
        }
    }

    func unDoneItemInList(listId: String, itemId: String) {
        if let listIndex = lists.firstIndex(where: { $0.id == listId }) {
            if let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == itemId }) {
                // Mark as undone
                lists[listIndex].items[itemIndex].done = false

                // Move to end of undone items (before first done item)
                let undoneItems = lists[listIndex].items.filter { !$0.done && $0.id != itemId }
                let maxUndoneOrder = undoneItems.map { $0.order }.max() ?? -1
                lists[listIndex].items[itemIndex].order = maxUndoneOrder + 1

                // Re-sort items
                lists[listIndex].items.sort(by: { $0.order < $1.order })

                let listRef = firestore.collection("lists").document(listId)
                listRef.updateData([
                    "items": lists[listIndex].items.map {
                        ["id": $0.id, "text": $0.text, "done": $0.done, "order": $0.order]
                    },
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated!")
                    }
                }
            }
        }
    }

    func deleteItemFromList(listId: String, itemId: String) {
        if let listIndex = lists.firstIndex(where: { $0.id == listId }) {
            if let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == itemId }) {
                lists[listIndex].items.remove(at: itemIndex)

                let listRef = firestore.collection("lists").document(listId)
                listRef.updateData([
                    "items": lists[listIndex].items.map {
                        ["id": $0.id, "text": $0.text, "done": $0.done, "order": $0.order]
                    },
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated!")
                    }
                }
            }
        }
    }
}
