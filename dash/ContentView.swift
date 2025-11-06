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

    @ObservedObject var deepLinkHandler: DeepLinkHandler

    @State private var showJoinAlert = false
    @State private var joinAlertMessage = ""
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
