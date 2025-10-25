//
//  TermsAndConditionsView.swift
//  dash
//
//  Terms and Conditions display
//

import SwiftUI

struct TermsAndConditionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms and Conditions")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.bottom, 10)

                Text("Last updated: \(getCurrentDate())")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                // Introduction
                TermsSectionView(
                    title: "1. Agreement to Terms",
                    content: "By accessing or using Dash, you agree to be bound by these Terms and Conditions. If you disagree with any part of these terms, you may not use our app."
                )

                // Account Terms
                TermsSectionView(
                    title: "2. Account Terms",
                    content: """
                    • You must be at least 13 years old to use this service
                    • You must provide a valid email address
                    • You are responsible for maintaining the security of your account
                    • You are responsible for all content and activity under your account
                    • You may not use the service for any illegal purposes
                    """
                )

                // User Content
                TermsSectionView(
                    title: "3. User Content",
                    content: """
                    • You retain all rights to the content you create (lists, items, etc.)
                    • You grant us the right to store and display your content
                    • You are responsible for the content you create and share
                    • We reserve the right to remove content that violates these terms
                    • You may not post content that is illegal, harmful, or offensive
                    """
                )

                // Shared Lists
                TermsSectionView(
                    title: "4. Shared Lists and Collaboration",
                    content: """
                    • When you share a list, other users can view and edit it
                    • You are responsible for who you share your lists with
                    • Collaborators must also follow these Terms and Conditions
                    • You can remove users from shared lists at any time
                    • We are not responsible for disputes between collaborators
                    """
                )

                // Prohibited Uses
                TermsSectionView(
                    title: "5. Prohibited Uses",
                    content: """
                    You may not use Dash to:

                    • Violate any laws or regulations
                    • Infringe on intellectual property rights
                    • Transmit malicious code or viruses
                    • Harass, abuse, or harm other users
                    • Spam or send unsolicited messages
                    • Attempt to gain unauthorized access to our systems
                    • Use automated systems to access the service
                    """
                )

                // Service Availability
                TermsSectionView(
                    title: "6. Service Availability",
                    content: """
                    • We strive to keep the service available 24/7
                    • We do not guarantee uninterrupted access
                    • We may modify or discontinue features at any time
                    • We may perform maintenance that temporarily affects availability
                    • We are not liable for any loss of data or service interruptions
                    """
                )

                // Intellectual Property
                TermsSectionView(
                    title: "7. Intellectual Property",
                    content: "The Dash app, including its design, features, and functionality, is owned by us and protected by copyright and trademark laws. You may not copy, modify, or distribute any part of the app without permission."
                )

                // Termination
                TermsSectionView(
                    title: "8. Termination",
                    content: """
                    • You may delete your account at any time
                    • We may suspend or terminate your account for violations
                    • Upon termination, your right to use the service ceases
                    • We may delete your data after account termination
                    • Certain provisions survive termination (e.g., liability limitations)
                    """
                )

                // Limitation of Liability
                TermsSectionView(
                    title: "9. Limitation of Liability",
                    content: """
                    TO THE MAXIMUM EXTENT PERMITTED BY LAW:

                    • The service is provided "as is" without warranties
                    • We are not liable for any indirect or consequential damages
                    • We are not liable for loss of data, profits, or business
                    • Our total liability is limited to the amount you paid us (if any)
                    • Some jurisdictions do not allow these limitations
                    """
                )

                // Indemnification
                TermsSectionView(
                    title: "10. Indemnification",
                    content: "You agree to indemnify and hold us harmless from any claims, damages, or expenses arising from your use of the service, your violation of these terms, or your violation of any rights of another user."
                )

                // Changes to Terms
                TermsSectionView(
                    title: "11. Changes to Terms",
                    content: "We reserve the right to modify these terms at any time. We will notify users of significant changes. Continued use of the service after changes constitutes acceptance of the new terms."
                )

                // Governing Law
                TermsSectionView(
                    title: "12. Governing Law",
                    content: "These terms are governed by the laws of [Your Country/State]. Any disputes will be resolved in the courts of [Your Jurisdiction]."
                )

                // Contact
                TermsSectionView(
                    title: "13. Contact Information",
                    content: "If you have any questions about these Terms and Conditions, please contact us at: legal@dashapp.com"
                )

                // Acceptance
                VStack(alignment: .leading, spacing: 8) {
                    Text("Acceptance of Terms")
                        .font(.system(size: 18, weight: .semibold))

                    Text("By using Dash, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.")
                        .font(.system(size: 15))
                        .foregroundColor(.primary.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 10)

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Terms & Conditions")
        .navigationBarTitleDisplayMode(.inline)
    }

    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

// MARK: - Terms Section View Component

struct TermsSectionView: View {
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

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TermsAndConditionsView()
        }
    }
}
