//
//  MainView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 17.
//

import FirebaseAuth
import SwiftUI

struct MainView: View {
    @AppStorage("uid") var userID: String = ""

    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView().preferredColorScheme(.light)
                .tabItem {
                    Image(systemName: "house")
                    Text("Lists")
                }
                .tag(0)

            CreateView().preferredColorScheme(.light)
                .tabItem {
                    Image(systemName: "plus.square.fill.on.square.fill")
                    Text("Create")
                }
                .tag(1)

            Button(action: {
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                    withAnimation {
                        userID = ""
                    }
                } catch let signOutError as NSError {
                    print("Error signing out: %@", signOutError)
                }
            }) {
                Text("Sign out")
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
            .tag(2)
        }
        .preferredColorScheme(.light)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
