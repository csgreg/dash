//
//  ProfileView.swift
//  dash
//
//  User profile with settings and account information
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ProfileView: View {
    @AppStorage("uid") var userID: String = ""
    @State private var userEmail: String = ""
    @State private var firstName: String = ""
    @State private var isEditingName: Bool = false
    @State private var showSignOutConfirmation: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var isDeleting: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color("purple"), Color("purple").opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)

                            Text(getInitials())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)

                        // Email
                        Text(userEmail)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)

                        // First Name Section
                        VStack(spacing: 8) {
                            if isEditingName {
                                HStack {
                                    TextField("First Name", text: $firstName)
                                        .font(.system(size: 20, weight: .semibold))
                                        .multilineTextAlignment(.center)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    Button(action: {
                                        saveFirstName()
                                        isEditingName = false
                                    }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(.horizontal, 40)
                            } else {
                                HStack(spacing: 8) {
                                    Text(firstName.isEmpty ? "Add your name" : firstName)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(firstName.isEmpty ? .gray : .primary)

                                    Button(action: {
                                        isEditingName = true
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color("purple"))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)

                    // Account Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            ProfileRow(
                                icon: "envelope.fill",
                                title: "Email",
                                value: userEmail,
                                iconColor: Color("purple")
                            )

                            Divider()
                                .padding(.leading, 60)

                            ProfileRow(
                                icon: "person.fill",
                                title: "User ID",
                                value: String(userID.prefix(8)) + "...",
                                iconColor: Color("purple")
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .padding(.horizontal)
                    }

                    // Settings Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settings")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            NavigationLink(destination: PrivacyPolicyView()) {
                                ProfileRow(
                                    icon: "lock.fill",
                                    title: "Privacy Policy",
                                    value: "",
                                    iconColor: .blue,
                                    showChevron: true
                                )
                            }

                            Divider()
                                .padding(.leading, 60)

                            NavigationLink(destination: TermsAndConditionsView()) {
                                ProfileRow(
                                    icon: "doc.text.fill",
                                    title: "Terms & Conditions",
                                    value: "",
                                    iconColor: .purple,
                                    showChevron: true
                                )
                            }

                            Divider()
                                .padding(.leading, 60)

                            Button(action: {
                                if let url = URL(string: "https://dashapp.live") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                ProfileRow(
                                    icon: "globe",
                                    title: "Website",
                                    value: "",
                                    iconColor: .green,
                                    showChevron: true
                                )
                            }

                            Divider()
                                .padding(.leading, 60)

                            NavigationLink(destination: FeedbackView()) {
                                ProfileRow(
                                    icon: "envelope.fill",
                                    title: "Send Feedback",
                                    value: "",
                                    iconColor: .orange,
                                    showChevron: true
                                )
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .padding(.horizontal)
                    }

                    VStack {
                        // Sign Out Button
                        Button(action: {
                            showSignOutConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)

                        // Delete Account Button
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            HStack {
                                if isDeleting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                } else {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Delete Account")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                        }
                        .disabled(isDeleting)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    // App Version
                    Text("Version 1.0.0")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
        .onAppear {
            loadUserData()
        }
        .confirmationDialog(
            "Sign Out",
            isPresented: $showSignOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                signOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all your data. This action cannot be undone.")
        }
    }

    // MARK: - Helper Functions

    func loadUserData() {
        // Get email from Firebase Auth
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? "No email"
        }

        // Load first name from Firestore using UserManager
        let userManager = UserManager(userId: userID)
        userManager.fetchUserFirstName { name in
            self.firstName = name
        }
    }

    func saveFirstName() {
        let userManager = UserManager(userId: userID)
        userManager.saveUserFirstName(firstName) { error in
            if let error = error {
                print("❌ Error saving first name: \(error)")
            } else {
                print("✅ First name saved successfully!")
            }
        }
    }

    func getInitials() -> String {
        if !firstName.isEmpty {
            return String(firstName.prefix(1)).uppercased()
        } else if !userEmail.isEmpty {
            return String(userEmail.prefix(1)).uppercased()
        }
        return "?"
    }

    func deleteAccount() {
        isDeleting = true

        let userManager = UserManager(userId: userID)
        let listManager = ListManager(userId: userID)

        // Step 1: Delete user document
        userManager.deleteUserDocument { error in
            if let error = error {
                print("❌ Error deleting user document: \(error)")
            }
        }

        // Step 2: Delete all user's lists
        listManager.deleteAllUserLists { error in
            if let error = error {
                print("❌ Error deleting lists: \(error)")
            }
        }

        // Step 3: Delete user from Firebase Auth
        userManager.deleteUserAccount { error in
            self.isDeleting = false

            if let error = error {
                print("❌ Error deleting user account: \(error)")
                // Show error alert if needed
            } else {
                print("✅ User account deleted successfully")
                // Sign out to return to login screen
                self.signOut()
            }
        }
    }

    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            withAnimation {
                userID = ""
            }
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
}

// MARK: - Profile Row Component

struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    var showChevron: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }

            // Title
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)

            Spacer()

            // Value or Chevron
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            } else if !value.isEmpty {
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding()
        .contentShape(Rectangle())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
