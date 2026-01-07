//
//  UserManager.swift
//  dash
//
//  Manages user-related Firebase operations
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import OSLog
import SwiftUI

extension Notification.Name {
    static let totalItemsCreatedDidChange = Notification.Name("totalItemsCreatedDidChange")
}

class UserManager {
    private let firestore = Firestore.firestore()
    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    // MARK: - Local Cache Helpers

    /// Get cached first name from AppStorage
    static func getCachedFirstName() -> String {
        return UserDefaults.standard.string(forKey: "cachedFirstName") ?? ""
    }

    /// Save first name to AppStorage for instant access
    static func cacheFirstName(_ name: String) {
        UserDefaults.standard.set(name, forKey: "cachedFirstName")
        AppLogger.database.debug("Cached first name locally")
    }

    /// Clear cached first name (useful on logout)
    static func clearCachedFirstName() {
        UserDefaults.standard.removeObject(forKey: "cachedFirstName")
        AppLogger.database.debug("Cleared cached first name")
    }

    static func getCachedTotalItemsCreated(userId: String) -> Int {
        UserDefaults.standard.integer(forKey: "cachedTotalItemsCreated_\(userId)")
    }

    static func cacheTotalItemsCreated(_ count: Int, userId: String) {
        UserDefaults.standard.set(count, forKey: "cachedTotalItemsCreated_\(userId)")
        NotificationCenter.default.post(
            name: .totalItemsCreatedDidChange,
            object: nil,
            userInfo: ["userId": userId, "count": count]
        )
    }

    // MARK: - User Profile

    func fetchUserFirstName(completion: @escaping (String) -> Void) {
        let userRef = firestore.collection("users").document(userId)

        userRef.getDocument { document, _ in
            if let document = document, document.exists {
                let firstName = document.data()?["firstName"] as? String ?? ""
                // Cache the fetched name for instant access next time
                UserManager.cacheFirstName(firstName)
                completion(firstName)
            } else {
                completion("")
            }
        }
    }

    func saveUserFirstName(_ firstName: String, completion: @escaping (Error?) -> Void) {
        // Cache immediately for instant access
        UserManager.cacheFirstName(firstName)

        let userRef = firestore.collection("users").document(userId)

        userRef.setData([
            "firstName": firstName,
            "userId": userId,
        ], merge: true) { error in
            if let error = error {
                AppLogger.database.error("Failed to save first name: \(error.localizedDescription)")
                completion(error)
            } else {
                AppLogger.database.notice("First name saved to Firestore")
                completion(nil)
            }
        }
    }

    // MARK: - User Stats

    func incrementItemCount() {
        let cached = UserManager.getCachedTotalItemsCreated(userId: userId)
        UserManager.cacheTotalItemsCreated(cached + 1, userId: userId)

        let userRef = firestore.collection("users").document(userId)

        AppLogger.database.debug("Incrementing item count")

        userRef.setData([
            "totalItemsCreated": FieldValue.increment(Int64(1)),
            "userId": userId,
        ], merge: true) { error in
            if let error = error {
                AppLogger.database.error("Failed to increment item count: \(error.localizedDescription)")
            } else {
                AppLogger.database.info("Item count incremented")
            }
        }
    }

    func fetchUserItemCount(completion: @escaping (Int) -> Void) {
        let userRef = firestore.collection("users").document(userId)

        AppLogger.database.debug("Fetching item count")

        userRef.getDocument { document, _ in
            if let document = document, document.exists {
                let count = document.data()?["totalItemsCreated"] as? Int ?? 0
                AppLogger.database.info("Fetched item count: \(count, privacy: .public)")
                UserManager.cacheTotalItemsCreated(count, userId: self.userId)
                completion(count)
            } else {
                AppLogger.database.debug("User document doesn't exist, returning 0")
                UserManager.cacheTotalItemsCreated(0, userId: self.userId)
                completion(0)
            }
        }
    }

    // MARK: - Account Deletion

    func deleteUserDocument(completion: @escaping (Error?) -> Void) {
        let userRef = firestore.collection("users").document(userId)

        userRef.delete { error in
            if let error = error {
                AppLogger.database.error("Failed to delete user document: \(error.localizedDescription)")
                completion(error)
            } else {
                AppLogger.database.notice("User document deleted")
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
                AppLogger.auth.error("Failed to delete user account: \(error.localizedDescription)")
                completion(error)
            } else {
                AppLogger.auth.notice("User account deleted")
                completion(nil)
            }
        }
    }
}
