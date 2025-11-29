//
//  AppLogger.swift
//  dash
//
//  Centralized logging for production monitoring
//

import Foundation
import OSLog

/// Centralized logging system using OSLog for production-ready monitoring
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.dash.app"

    // Category-specific loggers
    static let database = Logger(subsystem: subsystem, category: "database")
    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    static let network = Logger(subsystem: subsystem, category: "network")
    static let rewards = Logger(subsystem: subsystem, category: "rewards")
    static let general = Logger(subsystem: subsystem, category: "general")
}
