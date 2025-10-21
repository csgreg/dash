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

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
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
            .navigationTitle("Hey! 👋")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("Your lists")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ListManager(userId: "asd"))
    }
}
