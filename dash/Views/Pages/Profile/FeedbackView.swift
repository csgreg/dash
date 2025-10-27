//
//  FeedbackView.swift
//  dash
//
//  In-app feedback form
//

import FirebaseFirestore
import SwiftUI

struct FeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("uid") var userID: String = ""

    @State private var feedbackText: String = ""
    @State private var feedbackType: FeedbackType = .general
    @State private var userEmail: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    enum FeedbackType: String, CaseIterable {
        case bug = "Bug Report"
        case feature = "Feature Request"
        case general = "General Feedback"
        case other = "Other"

        var icon: String {
            switch self {
            case .bug: return "ladybug.fill"
            case .feature: return "lightbulb.fill"
            case .general: return "message.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .bug: return .red
            case .feature: return .blue
            case .general: return .green
            case .other: return .gray
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("We'd love to hear from you!")
                        .font(.system(size: 24, weight: .bold))

                    Text("Your feedback helps us improve Dash")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)

                // Feedback Type Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Feedback Type")
                        .font(.system(size: 17, weight: .semibold))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(FeedbackType.allCases, id: \.self) { type in
                            FeedbackTypeButton(
                                type: type,
                                isSelected: feedbackType == type,
                                action: { feedbackType = type }
                            )
                        }
                    }
                }

                // Email Field (Optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email (Optional)")
                        .font(.system(size: 17, weight: .semibold))

                    Text("We'll use this to follow up if needed")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)

                    TextField("your.email@example.com", text: $userEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                // Feedback Text
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Feedback")
                        .font(.system(size: 17, weight: .semibold))

                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 150)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if feedbackText.isEmpty {
                                    Text("Tell us what's on your mind...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.top, 16)
                                        .padding(.leading, 12)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }

                // Character Count
                HStack {
                    Spacer()
                    Text("\(feedbackText.count) characters")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                // Submit Button
                Button(action: submitFeedback) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text("Submit Feedback")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(feedbackText.isEmpty ? Color.gray : Color("purple"))
                    )
                }
                .disabled(feedbackText.isEmpty || isSubmitting)

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Feedback Sent!", isPresented: $showSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Thank you for your feedback! We'll review it soon.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    func submitFeedback() {
        guard !feedbackText.isEmpty else { return }

        isSubmitting = true

        let db = Firestore.firestore()
        let feedbackRef = db.collection("feedback").document()

        var feedbackData: [String: Any] = [
            "userId": userID,
            "type": feedbackType.rawValue,
            "message": feedbackText,
            "timestamp": FieldValue.serverTimestamp(),
            "appVersion": "1.0.0",
            "status": "new",
        ]

        if !userEmail.isEmpty {
            feedbackData["email"] = userEmail
        }

        feedbackRef.setData(feedbackData) { error in
            isSubmitting = false

            if let error = error {
                errorMessage = "Failed to submit feedback. Please try again."
                showErrorAlert = true
                print("❌ Error submitting feedback: \(error)")
            } else {
                print("✅ Feedback submitted successfully!")
                showSuccessAlert = true
            }
        }
    }
}

// MARK: - Feedback Type Button Component

struct FeedbackTypeButton: View {
    let type: FeedbackView.FeedbackType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? type.color : .gray)

                Text(type.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .primary : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? type.color.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? type.color : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedbackView()
        }
    }
}
