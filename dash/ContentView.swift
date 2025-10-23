//
//  ContentView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import FirebaseAuth
import SwiftUI

struct ContentView: View {
    var userId: String

    var listManager: ListManager
    @ObservedObject var deepLinkHandler: DeepLinkHandler

    @State private var showJoinAlert = false
    @State private var joinAlertMessage = ""
    @State private var pendingListId: String?

    init(userId: String, deepLinkHandler: DeepLinkHandler) {
        self.userId = userId
        self.deepLinkHandler = deepLinkHandler
        listManager = ListManager(userId: self.userId)
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
            } else {
                MainView()
                    .environmentObject(listManager)
                    .alert("Join List", isPresented: $showJoinAlert) {
                        Button("Cancel", role: .cancel) {
                            deepLinkHandler.reset()
                        }
                    } message: {
                        Text(joinAlertMessage)
                    }
            }
        }
        .onChange(of: deepLinkHandler.activeDeepLink) { newValue in
            handleDeepLink(newValue)
        }
    }

    private func handleDeepLink(_ deepLink: DeepLink) {
        guard case let .joinList(listId) = deepLink else { return }

        // If user is not logged in, show login prompt
        if userId.isEmpty {
            showJoinAlert = true
            return
        }

        // Auto-join the list
        listManager.joinToList(listId: listId, userId: userId) { message in
            joinAlertMessage = message
            showJoinAlert = true
            deepLinkHandler.reset()
        }
    }
}
