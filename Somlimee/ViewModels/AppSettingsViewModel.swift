//
//  AppSettingsViewModel.swift
//  Somlimee
//

import Foundation

protocol AppSettingsViewModel {
    var commentNotificationsEnabled: Bool { get set }
    var darkModeEnabled: Bool { get set }
    func loadSettings()
    func saveSettings()
}

@Observable
final class AppSettingsViewModelImpl: AppSettingsViewModel {
    var commentNotificationsEnabled: Bool = true
    var darkModeEnabled: Bool = false

    private let defaults = UserDefaults.standard
    private let commentNotifKey = "commentNotificationsEnabled"
    private let darkModeKey = "darkModeEnabled"

    init() {
        loadSettings()
    }

    func loadSettings() {
        Log.vm.debug("AppSettingsViewModel.loadSettings: start")
        if defaults.object(forKey: commentNotifKey) != nil {
            commentNotificationsEnabled = defaults.bool(forKey: commentNotifKey)
        }
        darkModeEnabled = defaults.bool(forKey: darkModeKey)
        Log.vm.debug("AppSettingsViewModel.loadSettings: commentNotif=\(self.commentNotificationsEnabled) darkMode=\(self.darkModeEnabled)")
    }

    func saveSettings() {
        Log.vm.info("AppSettingsViewModel.saveSettings: commentNotif=\(self.commentNotificationsEnabled) darkMode=\(self.darkModeEnabled)")
        defaults.set(commentNotificationsEnabled, forKey: commentNotifKey)
        defaults.set(darkModeEnabled, forKey: darkModeKey)
    }
}
