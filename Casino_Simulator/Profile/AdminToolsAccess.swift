// Path: Profile/AdminToolsAccess.swift

import SwiftUI
import Combine

final class AdminToolsAccess: ObservableObject {
    @AppStorage("admin_tools_enabled") private var adminToolsEnabledStorage: Bool = false
    @AppStorage("admin_unlock_all_games") private var unlockAllGamesStorage: Bool = false

    @Published var isPanelAvailable: Bool
    @Published var isAllGamesUnlockedForTesting: Bool

    init() {
        let panelValue = UserDefaults.standard.bool(forKey: "admin_tools_enabled")
        let unlockValue = UserDefaults.standard.bool(forKey: "admin_unlock_all_games")

        isPanelAvailable = panelValue
        isAllGamesUnlockedForTesting = unlockValue
    }

    func enablePanel() {
        adminToolsEnabledStorage = true
        isPanelAvailable = true
    }

    func disablePanel() {
        adminToolsEnabledStorage = false
        isPanelAvailable = false
    }

    func setUnlockAllGames(_ value: Bool) {
        unlockAllGamesStorage = value
        isAllGamesUnlockedForTesting = value
    }

    func reloadFromStorage() {
        isPanelAvailable = UserDefaults.standard.bool(forKey: "admin_tools_enabled")
        isAllGamesUnlockedForTesting = UserDefaults.standard.bool(forKey: "admin_unlock_all_games")
    }
}
