//
//  AppearanceManager.swift
//  dash
//
//  Manages app appearance and dark mode preferences
//

import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

class AppearanceManager: ObservableObject {
    @AppStorage("appearanceMode") var appearanceMode: String = AppearanceMode.system.rawValue

    var currentMode: AppearanceMode {
        get {
            AppearanceMode(rawValue: appearanceMode) ?? .system
        }
        set {
            appearanceMode = newValue.rawValue
        }
    }

    var preferredColorScheme: ColorScheme? {
        currentMode.colorScheme
    }
}
