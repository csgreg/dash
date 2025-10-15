//
//  ListManager.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 27.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

/// Manages list data and operations with Firebase Firestore
class ListManager: ObservableObject {
    var userId: String
    
    private let db = Firestore.firestore()
    
    @Published var lists: [Listy] = []
    @Published var currentListIndex = 0
    @Published var isLoading: Bool = true
    
    init(userId: String) {
        self.userId = userId
        Task{
            await fetchLists()
        }
    }
    
    func fetchLists() async {
        db.collection("lists").whereField("users", arrayContains: userId)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    if let error = error {
                        print("Error fetching documents: \(error.localizedDescription)")
                    }
                    return
                }
                var incomingLists: [Listy] = []
                documents.forEach{ data in
                    let name = data["name"]! as? String ?? ""
                    let users = data["users"]! as? [String] ?? []
                    var list = Listy(id: data.documentID, name: name, items: [], users: users)
                    let items = data["items"] as? NSArray as? [NSDictionary] as? [Dictionary<String, Any>]
                    items?.forEach{  item in
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
                print("DB updated, lists:", self.lists)
            }
            self.isLoading = false
    }
    
    func createList(listName: String, completion: @escaping(String) -> Void) {
        let uid = UUID().uuidString
        db.collection("lists").document(uid).setData([
            "name": listName,
            "items": [],
            "users": [self.userId],
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
    
    func joinToList(listId: String, userId: String, completion: @escaping(String) -> Void){
        if self.lists.contains(where: {$0.id == listId}) {
            completion("Your profile already have this list.")
            return
        }
        let docRef = db.collection("lists").document(listId)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let data{
                    let id = document.documentID
                    let name = data["name"] as? String ?? ""
                    var users = data["users"] as? [String] ?? []
                    users.append(userId)
                    var list = Listy(id: id, name: name, items: [], users: users)
                    let items = data["items"] as? NSArray as? [NSDictionary] as? [Dictionary<String, Any>]
                    items?.forEach{ item in
                        let text = item["text"] as? String ?? ""
                        let id = item["id"] as? String ?? ""
                        let done = item["done"] as? Bool ?? false
                        let order = item["order"] as? Int ?? 0
                        list.items.append(Item(id: id, text: text, done: done, order: order))
                    }
                    self.lists.append(list)
                    
                    docRef.updateData([
                        "users": users
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
        if let index = self.lists.firstIndex(where: {$0.id == listId}){
            self.lists[index].items.append(item)
            let listRef = db.collection("lists").document(listId)
            
            listRef.updateData([
                "items": self.lists[index].items.map{
                    ["id": $0.id, "text": $0.text, "done": $0.done, "order": $0.order]
                }
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated!")
                }
            }
        }
    }
    
    func updateItemsInList(listId: String, items: [Item]){
        if let index = self.lists.firstIndex(where: {$0.id == listId}){
            let listRef = db.collection("lists").document(listId)
            
            listRef.updateData([
                "items": items.map{
                    ["id": $0.id, "text": $0.text, "done": $0.done, "order": $0.order]
                }
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated!")
                }
            }
        }
    }
    
    func setSelectedList(listId: String){
        if let index = self.lists.firstIndex(where: {$0.id == listId}) {
            self.currentListIndex = index
        }
    }
    
    func deleteList(listId: String){
        self.lists = self.lists.filter {$0.id != listId}
        db.collection("lists").document(listId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func doneItemInList(listId: String, itemId: String){
        if let listIndex = self.lists.firstIndex(where: {$0.id == listId}){
            if let itemIndex = self.lists[listIndex].items.firstIndex(where: {$0.id == itemId}){
                // Mark as done
                self.lists[listIndex].items[itemIndex].done = true
                
                // Move to end: set order to max + 1
                let maxOrder = self.lists[listIndex].items.map { $0.order }.max() ?? 0
                self.lists[listIndex].items[itemIndex].order = maxOrder + 1
                
                // Re-sort items
                self.lists[listIndex].items.sort(by: { $0.order < $1.order })
                
                let listRef = db.collection("lists").document(listId)
                listRef.updateData([
                    "items": self.lists[listIndex].items.map {
                        ["id": $0.id, "text": $0.text, "done": $0.done, "order": $0.order]
                    }
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
    
    func unDoneItemInList(listId: String, itemId: String){
        if let listIndex = self.lists.firstIndex(where: {$0.id == listId}){
            if let itemIndex = self.lists[listIndex].items.firstIndex(where: {$0.id == itemId}){
                // Mark as undone
                self.lists[listIndex].items[itemIndex].done = false
                
                // Move to end of undone items (before first done item)
                let undoneItems = self.lists[listIndex].items.filter { !$0.done && $0.id != itemId }
                let maxUndoneOrder = undoneItems.map { $0.order }.max() ?? -1
                self.lists[listIndex].items[itemIndex].order = maxUndoneOrder + 1
                
                // Re-sort items
                self.lists[listIndex].items.sort(by: { $0.order < $1.order })
                
                let listRef = db.collection("lists").document(listId)
                listRef.updateData([
                    "items": self.lists[listIndex].items.map {
                        ["id": $0.id, "text": $0.text, "done": $0.done, "order": $0.order]
                    }
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
    
    func deleteItemFromList(listId: String, itemId: String){
        if let listIndex = self.lists.firstIndex(where: {$0.id == listId}){
            if let itemIndex = self.lists[listIndex].items.firstIndex(where: {$0.id == itemId}){
                self.lists[listIndex].items.remove(at: itemIndex)
                
                let listRef = db.collection("lists").document(listId)
                listRef.updateData([
                    "items": self.lists[listIndex].items.map {
                        ["id": $0.id, "text": $0.text, "done": $0.done, "order": $0.order]
                    }
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
