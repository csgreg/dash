//
//  ContentView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import FirebaseAuth
import OSLog
import SwiftUI

struct ContentView: View {
    var userId: String

    @ObservedObject var deepLinkHandler: DeepLinkHandler
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    @State private var showJoinAlert = false
    @State private var joinAlertMessage = ""
    @State private var joinSuccess = false
    @State private var navigateToHome = false
    @State private var pendingListId: String?
    @State private var listManager: ListManager

    init(userId: String, deepLinkHandler: DeepLinkHandler) {
        self.userId = userId
        self.deepLinkHandler = deepLinkHandler
        _listManager = State(initialValue: ListManager(userId: userId))
    }

    var body: some View {
        Group {
            if userId.isEmpty {
                AuthView()
                    .alert("Login Required", isPresented: $showJoinAlert) {
                        Button("OK", role: .cancel) {
                            deepLinkHandler.reset()
                        }
                    } message: {
                        Text("Please log in to join this list.")
                    }
            } else if !hasCompletedOnboarding {
                // Show onboarding for new users
                OnboardingView()
                    .transition(.opacity)
            } else {
                MainView(selectedTab: $navigateToHome)
                    .environmentObject(listManager)
                    .id(userId)
                    .alert(joinSuccess ? "Success!" : "Join List", isPresented: $showJoinAlert) {
                        Button(joinSuccess ? "View Lists" : "OK", role: joinSuccess ? nil : .cancel) {
                            if joinSuccess {
                                navigateToHome = true
                            }
                            deepLinkHandler.reset()
                        }
                    } message: {
                        Text(joinAlertMessage)
                    }
            }
        }
        .onChange(of: userId) { newUserId in
            // Recreate ListManager when userId changes
            if !newUserId.isEmpty {
                listManager = ListManager(userId: newUserId)
            }
        }
        .onChange(of: deepLinkHandler.activeDeepLink) { newValue in
            handleDeepLink(newValue)
        }
    }

    private func handleDeepLink(_ deepLink: DeepLink) {
        guard case let .joinList(joinCode) = deepLink else { return }

        // If user is not logged in, show login prompt
        if userId.isEmpty {
            showJoinAlert = true
            return
        }

        // Auto-join the list using joinCode
        listManager.joinToList(joinCode: joinCode, userId: userId) { success, message in
            joinSuccess = success
            joinAlertMessage = message
            showJoinAlert = true

            // If successful, navigate to home after alert is dismissed
            if success {
                AppLogger.ui.info("Join successful, will navigate to home")
            }

            deepLinkHandler.reset()
        }
    }
}
