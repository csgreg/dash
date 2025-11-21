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

                Text("Last updated: \(getCurrentDate())")
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
                    • Usage statistics (items created, achievements)
                    • Device information (for app functionality)
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
                    • Track achievements and rewards
                    • Improve our app and user experience
                    """
                )

                // Data Storage
                SectionView(
                    title: "Data Storage",
                    content: "Your data is stored securely using Firebase (Google Cloud Platform). We implement appropriate security measures to protect your personal information."
                )

                // Data Sharing
                SectionView(
                    title: "Data Sharing",
                    content: "We do not sell, trade, or rent your personal data to third parties. Your data is only shared with collaborators on lists you explicitly choose to share."
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
                    content: "We retain your data as long as your account is active. If you delete your account, we will delete your personal data within 30 days."
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
