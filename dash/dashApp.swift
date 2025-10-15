//
//  dashApp.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct dashApp: App {
    
    let myUrlScheme = "com.swiftcore.dash"
    
    @AppStorage("uid") private var userID: String = ""
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(userId: userID)
                .onOpenURL { url in
                    print(url)
                }
        }
    }
}
