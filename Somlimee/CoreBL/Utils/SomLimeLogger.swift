//
//  SomLimeLogger.swift
//  Somlimee
//

import Foundation
import os

/// Centralized logging for all Somlimee layers.
/// Uses `os.Logger` with subsystem/category pattern for Console.app filtering.
///
/// Usage:
///   Log.data.info("Fetched \(count) posts")
///   Log.vm.error("Failed to load profile: \(error)")
///
/// Filter in Console.app:
///   subsystem: com.borkenchj.Somlimee
///   category: Data / Repository / UseCase / ViewModel / Auth / UI / App
enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.borkenchj.Somlimee"

    /// Data layer (Firebase, SQLite)
    static let data = Logger(subsystem: subsystem, category: "Data")

    /// Repository layer
    static let repo = Logger(subsystem: subsystem, category: "Repository")

    /// UseCase layer
    static let useCase = Logger(subsystem: subsystem, category: "UseCase")

    /// ViewModel layer
    static let vm = Logger(subsystem: subsystem, category: "ViewModel")

    /// Authentication
    static let auth = Logger(subsystem: subsystem, category: "Auth")

    /// UI / Navigation
    static let ui = Logger(subsystem: subsystem, category: "UI")

    /// App lifecycle
    static let app = Logger(subsystem: subsystem, category: "App")
}

// MARK: - App-wide Notification Names

extension Notification.Name {
    /// Posted when the user logs in or logs out. Screens observe this to refresh their data.
    static let authStateDidChange = Notification.Name("com.borkenchj.Somlimee.authStateDidChange")
}
