//
//  HomeView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 18.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import RiveRuntime
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var listManager: ListManager
    @State private var firstName: String = ""
    @Binding var selectedTab: Int

    var body: some View {
        NavigationView {
            ScrollView {
                if listManager.lists.isEmpty {
                    EmptyStateView(onCreateList: {
                        selectedTab = 1
                    })
                } else {
                    ForEach(listManager.lists) { list in
                        NavigationLink {
                            ListDetailsView(listId: list.id)
                        } label: {
                            ListButton(
                                text: list.name, emoji: list.emoji, color: list.color, allItems: list.items.count,
                                completedItems: list.items.filter { $0.done }.count, sharedWith: list.users.count
                            ).transition(.slide).padding(.horizontal)
                        }.simultaneousGesture(
                            TapGesture().onEnded {
                                listManager.setSelectedList(listId: list.id)
                            })
                    }
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
                loadUserName()
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
