//
//  dashApp.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import FirebaseAnalytics
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    var deepLinkHandler: DeepLinkHandler?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        AnalyticsManager.configureFromStoredSetting()
        AnalyticsManager.logAppOpen()

        // Enable Firestore offline persistence for better offline handling
        let firestore = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        firestore.settings = settings

        return true
    }

    func application(
        _: UIApplication,
        open url: URL,
        options _: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // Handle Universal Links when app is not running or in background
    func application(
        _: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL
        else {
            return false
        }

        deepLinkHandler?.handleURL(url)
        return true
    }
}

@main
struct DashApp: App {
    @AppStorage("uid") private var userID: String = ""
    @StateObject private var deepLinkHandler = DeepLinkHandler()
    @StateObject private var appearanceManager = AppearanceManager()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView(userId: userID, deepLinkHandler: deepLinkHandler)
                .preferredColorScheme(appearanceManager.preferredColorScheme)
                .environmentObject(appearanceManager)
                .onAppear {
                    // Connect deepLinkHandler to AppDelegate for background handling
                    delegate.deepLinkHandler = deepLinkHandler
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    guard let url = userActivity.webpageURL else { return }
                    deepLinkHandler.handleURL(url)
                }
                .onOpenURL { url in
                    deepLinkHandler.handleURL(url)
                }
        }
    }
}
