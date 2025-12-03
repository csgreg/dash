//
//  HomeView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 18.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var listManager: ListManager
    @State private var firstName: String = ""
    @State private var activeListId: String?
    @Binding var selectedTab: Int

    var body: some View {
        NavigationView {
            ScrollView {
                if listManager.lists.isEmpty {
                    EmptyStateView(onCreateList: {
                        selectedTab = 1
                    })
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(listManager.lists) { list in
                            NavigationLink(
                                tag: list.id,
                                selection: $activeListId,
                                destination: {
                                    ListDetailsView(listId: list.id)
                                },
                                label: {
                                    ListButton(
                                        text: list.name, emoji: list.emoji, color: list.color,
                                        allItems: list.items.count,
                                        completedItems: list.items.filter { $0.done }.count,
                                        sharedWith: list.users.count
                                    )
                                    .transition(.slide)
                                    .padding(.horizontal)
                                }
                            )
                            .buttonStyle(.plain)
                            .onTapGesture {
                                listManager.setSelectedList(listId: list.id)
                                activeListId = list.id
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(getGreeting())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("Your lists")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
            .onAppear {
                // Load cached name immediately for instant display
                firstName = UserManager.getCachedFirstName()
                // Then fetch from Firestore to sync any updates
                loadUserName()
                activeListId = nil
            }
        }
    }

    func loadUserName() {
        listManager.fetchUserFirstName { name in
            firstName = name
        }
    }

    func getGreeting() -> String {
        if firstName.isEmpty {
            return "Hey! 👋"
        } else {
            return "Hey, \(firstName)! 👋"
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(0))
            .environmentObject(ListManager(userId: "asd"))
    }
}
