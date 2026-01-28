//
//  ProfileView.swift
//  dash
//
//  User profile with settings and account information
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import OSLog
import SwiftUI

struct ProfileView: View {
    @AppStorage("uid") var userID: String = ""
    @AppStorage(AnalyticsManager.analyticsEnabledKey) private var analyticsEnabled: Bool = true
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var rewardsManager: RewardsManager
    @State private var userEmail: String = ""
    @State private var firstName: String = ""
    @State private var isEditingName: Bool = false
    @State private var showSignOutConfirmation: Bool = false

    private var profileHeader: some View {
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
        return VStack(spacing: 0) {
            // Identity Row
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("purple"), Color("purple").opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: Color("purple").opacity(0.3), radius: 8, x: 0, y: 4)

                    Text(getInitials())
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }

                // Name & Email
                VStack(alignment: .leading, spacing: 4) {
                    if isEditingName {
                        HStack {
                            TextField("First Name", text: $firstName)
                                .font(.system(size: 20, weight: .bold))
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button(action: {
                                saveFirstName()
                                isEditingName = false
                            }) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.green)
                            }
                        }
                    } else {
                        HStack(spacing: 8) {
                            Text(firstName.isEmpty ? "Add your name" : firstName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(firstName.isEmpty ? .secondary : .primary)
                                .lineLimit(1)

                            Button(action: {
                                isEditingName = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("purple"))
                            }
                        }
                    }

                    Text(userEmail)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 20)

            Divider()
                .padding(.leading, 20)

            // Stats Row
            HStack(spacing: 0) {
                // Total Items
                VStack(spacing: 4) {
                    Text("\(rewardsManager.totalItemsCreated)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Total Items")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 30)

                // Current Status
                VStack(spacing: 4) {
                    Text(rewardsManager.getCurrentReward().title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text("Current Status")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .dashCardStyle(shape)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var settingsCard: some View {
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
        return VStack(spacing: 0) {
            // User ID
            ProfileRow(
                icon: "person.badge.shield.checkmark.fill",
                title: "User ID",
                value: String(userID.prefix(8)) + "...",
                iconColor: Color("purple")
            )

            Divider().padding(.leading, 64)

            // Appearance
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "moon.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.purple)
                }

                Text("Appearance")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                Picker("", selection: $appearanceManager.appearanceMode) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode.rawValue)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(Color("purple"))
            }
            .padding()

            Divider().padding(.leading, 64)

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                }

                Text("Analytics")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                Toggle("", isOn: $analyticsEnabled)
                    .labelsHidden()
                    .onChange(of: analyticsEnabled) { _, newValue in
                        AnalyticsManager.setEnabled(newValue)
                    }
            }
            .padding()

            Divider().padding(.leading, 64)

            // Privacy Policy
            NavigationLink(destination: PrivacyPolicyView()) {
                ProfileRow(
                    icon: "lock.shield.fill",
                    title: "Privacy Policy",
                    value: "",
                    iconColor: .blue,
                    showChevron: true
                )
            }

            Divider().padding(.leading, 64)

            // Terms
            Button(action: {
                if let url = URL(
                    string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
                ) {
                    UIApplication.shared.open(url)
                }
            }) {
                ProfileRow(
                    icon: "doc.text.fill",
                    title: "Terms of Service",
                    value: "",
                    iconColor: .gray,
                    showChevron: true
                )
            }

            Divider().padding(.leading, 64)

            // Website
            Button(action: {
                if let url = URL(string: "https://justdashapp.com") {
                    UIApplication.shared.open(url)
                }
            }) {
                ProfileRow(
                    icon: "globe",
                    title: "Website",
                    value: "",
                    iconColor: .cyan,
                    showChevron: true
                )
            }

            Divider().padding(.leading, 64)

            // Feedback
            NavigationLink(destination: FeedbackView()) {
                ProfileRow(
                    icon: "envelope.fill",
                    title: "Send Feedback",
                    value: "",
                    iconColor: .orange,
                    showChevron: true
                )
            }

            Divider().padding(.leading, 64)

            // Delete Account
            NavigationLink(destination: DeleteAccountView()) {
                ProfileRow(
                    icon: "trash.fill",
                    title: "Delete Account",
                    value: "",
                    iconColor: .red,
                    showChevron: true
                )
            }

            Divider().padding(.leading, 64)

            // Sign Out
            Button(action: {
                showSignOutConfirmation = true
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                    }

                    Text("Sign Out")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)

                    Spacer()
                }
                .padding()
                .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 12)
        .dashCardStyle(shape)
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    settingsCard

                    Text("Version 1.2.0")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.6))
                        .padding(.bottom, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("Profile")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
    }

    // MARK: - Helper Functions

    func loadUserData() {
        // Get email from Firebase Auth
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? "No email"
        }

        // Load cached first name immediately for instant display
        firstName = UserManager.getCachedFirstName()

        // Then fetch from Firestore to sync any updates
        let userManager = UserManager(userId: userID)
        userManager.fetchUserFirstName { name in
            self.firstName = name
        }
    }

    func saveFirstName() {
        let userManager = UserManager(userId: userID)
        userManager.saveUserFirstName(firstName) { error in
            if let error = error {
                AppLogger.database.error("Failed to save first name: \(error.localizedDescription)")
            } else {
                AppLogger.database.notice("First name saved")
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

    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            // Clear cached user data on logout
            UserManager.clearCachedFirstName()
            withAnimation {
                userID = ""
            }
        } catch let signOutError as NSError {
            AppLogger.auth.error("Failed to sign out: \(signOutError.localizedDescription)")
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
            .environmentObject(AppearanceManager())
            .environmentObject(RewardsManager(userId: "preview"))
    }
}
