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

    @Binding var selectedTab: Bool
    @State private var currentTab: Int = 0

    init(selectedTab: Binding<Bool> = .constant(false)) {
        _selectedTab = selectedTab
    }

    var body: some View {
        TabView(selection: $currentTab) {
            HomeView(selectedTab: $currentTab).preferredColorScheme(.light)
                .tabItem {
                    Image(systemName: "house")
                    Text("Lists")
                }
                .tag(0)

            CreateView(selectedTab: $currentTab).preferredColorScheme(.light)
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
        .onChange(of: currentTab) { _, newTab in
            logTabChange(newTab)
        }
        .onChange(of: selectedTab) { _, shouldNavigateHome in
            if shouldNavigateHome {
                currentTab = 0
                // Reset the binding after navigation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = false
                }
            }
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
