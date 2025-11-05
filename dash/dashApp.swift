//
//  dashApp.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        // Enable Firestore offline persistence for better offline handling
        let firestore = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        firestore.settings = settings

        return true
    }

    func application(_: UIApplication,
                     open url: URL,
                     options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct DashApp: App {
    @AppStorage("uid") private var userID: String = ""
    @StateObject private var deepLinkHandler = DeepLinkHandler()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView(userId: userID, deepLinkHandler: deepLinkHandler)
                .onOpenURL { url in
                    print("📱 Received URL: \(url.absoluteString)")
                    deepLinkHandler.handleURL(url)
                }
        }
    }
}
