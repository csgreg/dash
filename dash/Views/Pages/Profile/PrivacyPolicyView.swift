//
//  PrivacyPolicyView.swift
//  dash
//
//  Privacy Policy display
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.bottom, 10)

                Text("Last updated: 30.11.2025")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                // Introduction
                SectionView(
                    title: "Introduction",
                    content: "Welcome to Dash. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we handle your personal data when you use our app."
                )

                // Data We Collect
                SectionView(
                    title: "Data We Collect",
                    content: """
                    We collect and process the following data:

                    • Email address (for authentication)
                    • First name (optional, if provided)
                    • Lists and items you create
                    • Usage statistics (items created, rewards)
                    • Device information (for app functionality)
                    • Feedback submissions (optional email, message, type, timestamp)
                    • Authentication data from Apple or Google (when using third-party sign-in)
                    """
                )

                // How We Use Your Data
                SectionView(
                    title: "How We Use Your Data",
                    content: """
                    We use your data to:

                    • Provide and maintain our service
                    • Authenticate your account
                    • Sync your data across devices
                    • Track rewards and progress
                    • Improve our app and user experience
                    """
                )

                // Data Storage
                SectionView(
                    title: "Data Storage",
                    content: "Your data is stored securely using Firebase (Google Cloud Platform). We implement appropriate security measures to protect your personal information.\n\nWe also cache data locally on your device for offline access. This cached data syncs automatically when you're online and is deleted when you uninstall the app or delete your account."
                )

                // Third-Party Services
                SectionView(
                    title: "Third-Party Services",
                    content: """
                    We use the following third-party services to provide our app:

                    Firebase (Google): Authentication, database, and cloud storage
                    • Privacy Policy: firebase.google.com/support/privacy

                    Sign in with Apple: For authentication
                    • Privacy Policy: apple.com/legal/privacy

                    Google Sign-In: For authentication
                    • Privacy Policy: policies.google.com/privacy

                    These services may collect device and usage information as described in their privacy policies.
                    """
                )

                // Data Sharing
                SectionView(
                    title: "Data Sharing",
                    content: """
                    We do not sell, trade, or rent your personal data to third parties.

                    Your data may be shared in these limited circumstances:

                    • List Collaborators: When you share a list, collaborators can view the list name, items, and your user ID (not your email or personal information)

                    • Service Providers: Firebase/Google processes your data to provide cloud storage and authentication

                    • Legal Requirements: We may disclose data if required by law or to protect our rights
                    """
                )

                // Your Rights
                SectionView(
                    title: "Your Rights",
                    content: """
                    You have the right to:

                    • Access your personal data
                    • Correct inaccurate data
                    • Delete your account and data
                    • Export your data
                    • Withdraw consent at any time
                    """
                )

                // Data Retention
                SectionView(
                    title: "Data Retention",
                    content: """
                    We retain your data as long as your account is active. 

                    If you delete your account, we will immediately delete your user profile and all lists you created. 

                    For shared lists where you're a member (but not the creator), you will be removed from the list but the list itself will remain for other collaborators.
                    """
                )

                // Legal Basis
                SectionView(
                    title: "Legal Basis (EU Users)",
                    content: "For users in the European Union, we process your data based on your consent (provided when you accept this Privacy Policy) and to fulfill our contract to provide the app service."
                )

                // Contact
                SectionView(
                    title: "Contact Us",
                    content: "If you have any questions about this Privacy Policy, please contact us at: support@justdashapp.com"
                )

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

// MARK: - Section View Component

struct SectionView: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))

            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.primary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrivacyPolicyView()
        }
    }
}
