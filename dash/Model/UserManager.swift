//
//  UserManager.swift
//  dash
//
//  Manages user-related Firebase operations
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class UserManager {
    private let firestore = Firestore.firestore()
    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    // MARK: - User Profile

    func fetchUserFirstName(completion: @escaping (String) -> Void) {
        let userRef = firestore.collection("users").document(userId)

        userRef.getDocument { document, _ in
            if let document = document, document.exists {
                let firstName = document.data()?["firstName"] as? String ?? ""
                completion(firstName)
            } else {
                completion("")
            }
        }
    }

    func saveUserFirstName(_ firstName: String, completion: @escaping (Error?) -> Void) {
        let userRef = firestore.collection("users").document(userId)

        userRef.setData([
            "firstName": firstName,
            "userId": userId,
        ], merge: true) { error in
            if let error = error {
                print("❌ Error saving first name: \(error)")
                completion(error)
            } else {
                print("✅ First name saved successfully!")
                completion(nil)
            }
        }
    }

    // MARK: - User Stats

    func incrementItemCount() {
        let userRef = firestore.collection("users").document(userId)

        print("🎯 Incrementing item count for user: \(userId)")

        userRef.setData([
            "totalItemsCreated": FieldValue.increment(Int64(1)),
            "userId": userId,
        ], merge: true) { error in
            if let error = error {
                print("❌ Error incrementing item count: \(error)")
            } else {
                print("✅ Item count incremented successfully!")
            }
        }
    }

    func fetchUserItemCount(completion: @escaping (Int) -> Void) {
        let userRef = firestore.collection("users").document(userId)

        print("📊 Fetching item count for user: \(userId)")

        userRef.getDocument { document, _ in
            if let document = document, document.exists {
                let count = document.data()?["totalItemsCreated"] as? Int ?? 0
                print("📈 Fetched count: \(count)")
                completion(count)
            } else {
                print("⚠️ User document doesn't exist yet, returning 0")
                completion(0)
            }
        }
    }

    // MARK: - Account Deletion

    func deleteUserDocument(completion: @escaping (Error?) -> Void) {
        let userRef = firestore.collection("users").document(userId)

        userRef.delete { error in
            if let error = error {
                print("❌ Error deleting user document: \(error)")
                completion(error)
            } else {
                print("✅ User document deleted")
                completion(nil)
            }
        }
    }

    func deleteUserAccount(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "UserManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
            return
        }

        user.delete { error in
            if let error = error {
                print("❌ Error deleting user account: \(error)")
                completion(error)
            } else {
                print("✅ User account deleted successfully")
                completion(nil)
            }
        }
    }
}
