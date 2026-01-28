import FirebaseAnalytics
import Foundation

enum AnalyticsManager {
    static let analyticsEnabledKey = "analytics_enabled"

    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: analyticsEnabledKey) as? Bool ?? true
    }

    static func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: analyticsEnabledKey)
        Analytics.setAnalyticsCollectionEnabled(enabled)
    }

    static func configureFromStoredSetting() {
        Analytics.setAnalyticsCollectionEnabled(isEnabled)
    }

    static func logAppOpen() {
        guard isEnabled else { return }
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }

    static func logLoginSuccess(method: String) {
        guard isEnabled else { return }
        Analytics.logEvent("login_success", parameters: [
            "method": method,
        ])
    }

    static func logItemCreated(kind: String) {
        guard isEnabled else { return }
        Analytics.logEvent("item_created", parameters: [
            "kind": kind,
        ])
    }

    static func logScreenView(screenName: String) {
        guard isEnabled else { return }
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
        ])
    }
}
