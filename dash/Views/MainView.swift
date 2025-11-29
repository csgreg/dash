//
//  MainView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 17.
//

import FirebaseAuth
import OSLog
import SwiftUI

struct MainView: View {
    @AppStorage("uid") var userID: String = ""

    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab).preferredColorScheme(.light)
                .tabItem {
                    Image(systemName: "house")
                    Text("Lists")
                }
                .tag(0)

            CreateView(selectedTab: $selectedTab).preferredColorScheme(.light)
                .tabItem {
                    Image(systemName: "plus.square.fill.on.square.fill")
                    Text("Create")
                }
                .tag(1)

            RewardsView().preferredColorScheme(.light)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Rewards")
                }
                .tag(2)

            ProfileView().preferredColorScheme(.light)
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .preferredColorScheme(.light)
        .onChange(of: selectedTab) { _, newTab in
            logTabChange(newTab)
        }
        .onAppear {
            AppLogger.ui.notice("App session started")
        }
    }

    private func logTabChange(_ tab: Int) {
        let tabName: String
        switch tab {
        case 0: tabName = "Lists"
        case 1: tabName = "Create"
        case 2: tabName = "Rewards"
        case 3: tabName = "Profile"
        default: tabName = "Unknown"
        }
        AppLogger.ui.debug("Tab changed to: \(tabName, privacy: .public)")
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
