//
//  DeleteAccountView.swift
//  dash
//
//  Delete account confirmation page
//

import FirebaseAuth
import FirebaseFirestore
import OSLog
import SwiftUI

struct DeleteAccountView: View {
    @AppStorage("uid") var userID: String = ""
    @Environment(\.dismiss) var dismiss
    @State private var isDeleting: Bool = false
    @State private var showDeleteConfirmation: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            // Warning Icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
            }
            .padding(.top, 40)

            // Title and Description
            VStack(spacing: 16) {
                Text("Delete Account")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                Text("This action cannot be undone")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.secondary)
            }

            // Warning Information
            VStack(alignment: .leading, spacing: 16) {
                Text("What will be deleted:")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 12) {
                    DeleteInfoRow(
                        icon: "person.fill.xmark",
                        text: "Account and profile information"
                    )
                    DeleteInfoRow(
                        icon: "list.bullet",
                        text: "All lists you created"
                    )
                    DeleteInfoRow(
                        icon: "checkmark.circle",
                        text: "All your list items and progress"
                    )
                    DeleteInfoRow(
                        icon: "person.2.slash",
                        text: "You'll be removed from shared lists"
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.05))
            )
            .padding(.horizontal)

            Spacer()

            // Delete Button
            VStack(spacing: 20) {
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    HStack(spacing: 12) {
                        if isDeleting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("Delete My Account")
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Color.red,
                        in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                    )
                    .shadow(color: Color.red.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .disabled(isDeleting)
                .padding(.horizontal)

                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 32)
            }
        }

        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all your data. This action cannot be undone.")
        }
    }

    // MARK: - Delete Account Function

    func deleteAccount() {
        isDeleting = true

        let userManager = UserManager(userId: userID)

        // Step 1: Delete user document
        userManager.deleteUserDocument { error in
            if let error = error {
                AppLogger.database.error("Failed to delete user document: \(error.localizedDescription)")
            }
        }

        // Step 2: Delete all user's lists
        deleteAllUserListsDirectly()

        // Step 3: Delete user from Firebase Auth
        userManager.deleteUserAccount { error in
            self.isDeleting = false

            if let error = error {
                AppLogger.auth.error("Failed to delete user account: \(error.localizedDescription)")
            } else {
                AppLogger.auth.notice("User account deleted")
                // Sign out to return to login screen
                self.signOut()
            }
        }
    }

    private func deleteAllUserListsDirectly() {
        let firestore = Firestore.firestore()

        firestore.collection("lists")
            .whereField("users", arrayContains: userID)
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }

                for document in documents {
                    let data = document.data()
                    let creatorId = data["creatorId"] as? String

                    if creatorId == self.userID {
                        // Delete owned lists
                        document.reference.delete()
                        AppLogger.database.info("Deleted owned list during account deletion")
                    } else {
                        // Remove user from shared lists
                        var users = data["users"] as? [String] ?? []
                        users.removeAll { $0 == self.userID }
                        document.reference.updateData(["users": users])
                        AppLogger.database.info("Left shared list during account deletion")
                    }
                }
            }
    }

    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            UserManager.clearCachedFirstName()
            withAnimation {
                userID = ""
            }
        } catch let signOutError as NSError {
            AppLogger.auth.error("Failed to sign out: \(signOutError.localizedDescription)")
        }
    }
}

// MARK: - Delete Info Row Component

struct DeleteInfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

// MARK: - Preview

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeleteAccountView()
        }
    }
}
