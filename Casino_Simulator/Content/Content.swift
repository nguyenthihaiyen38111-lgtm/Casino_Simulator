// Path: Content/Content.swift

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var profile = GameCasProfSt.shared
    @StateObject private var avatarStore = ProfileAvatarStore.shared

    @State private var selectedTab: ProjectClubTabBar.Tab = .lobby
    @State private var activeCasino: GameCasProfSt.CasinoMode?
    @State private var showProfile = false
    @State private var lockedAlert: LockedModeAlert?

    private enum Assets {
        static let background = "back_lobby"

        static let tabLobby = "home"
        static let tabAchievs = "Achievements"
        static let tabGame = "Games"
        static let tabQuests = "Quests"
        static let tabUnlocks = "crown"
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let isCompact = w <= 375

            let sideInset: CGFloat = isCompact ? 22 : 24
            let bottomSafe = proxy.safeAreaInsets.bottom

            let tabLift: CGFloat = isCompact ? 10 : 12
            let tabBottomPad: CGFloat = bottomSafe + tabLift

            let tabWidth = max(0, w - (sideInset * 2))
            let tabHeight = ProjectClubTabBar.preferredHeight(forWidth: tabWidth)
            let screensBottomInset = tabBottomPad + tabHeight + (isCompact ? 18 : 22)

            ZStack {
                Image(Assets.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                switch selectedTab {
                case .lobby:
                    LobbyView(
                        bottomInset: screensBottomInset,
                        onOpenProfile: {
                            showProfile = true
                        },
                        onOpenCasino: { game in
                            openCasino(game)
                        }
                    )
                    .environmentObject(profile)
                    .environmentObject(avatarStore)

                case .achievs:
                    AchievementsView(bottomInset: screensBottomInset)
                        .environmentObject(profile)

                case .game:
                    GamesView(
                        bottomInset: screensBottomInset,
                        onOpenProfile: {
                            showProfile = true
                        },
                        onOpenCasino: { game in
                            openCasino(game)
                        }
                    )
                    .environmentObject(profile)
                    .environmentObject(avatarStore)

                case .quests:
                    QuestsView(bottomInset: screensBottomInset)
                        .environmentObject(profile)

                case .unlocks:
                    UnlocksView(bottomInset: screensBottomInset)
                        .environmentObject(profile)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .overlay(alignment: .bottom) {
                ProjectClubTabBar(
                    items: [
                        .init(tab: .lobby, icon: Assets.tabLobby, title: "Home"),
                        .init(tab: .achievs, icon: Assets.tabAchievs, title: "Achievements"),
                        .init(tab: .game, icon: Assets.tabGame, title: "Games"),
                        .init(tab: .quests, icon: Assets.tabQuests, title: "Quests"),
                        .init(tab: .unlocks, icon: Assets.tabUnlocks, title: "Unlocks")
                    ],
                    selected: selectedTab,
                    onSelect: { selectedTab = $0 },
                    availableWidth: tabWidth
                )
                .padding(.horizontal, sideInset)
                .padding(.bottom, tabBottomPad)
                .allowsHitTesting(true)
            }
            .alert(item: $lockedAlert) { item in
                Alert(
                    title: Text("Mode Locked"),
                    message: Text(profile.unlockMessage(for: item.mode)),
                    dismissButton: .default(Text("OK"))
                )
            }
            .fullScreenCover(item: $activeCasino, onDismiss: {
                activeCasino = nil
            }) { game in
                CasinoHostView(
                    game: game,
                    onClose: {
                        activeCasino = nil
                    }
                )
                .id("casino-\(game.rawValue)")
                .environmentObject(profile)
                .environmentObject(avatarStore)
            }
            .fullScreenCover(isPresented: $showProfile) {
                ProfileView(onClose: {
                    showProfile = false
                })
                .environmentObject(profile)
                .environmentObject(avatarStore)
            }
        }
        .environmentObject(profile)
        .environmentObject(avatarStore)
        .onAppear {
            profile.registerAppLaunch()
            profile.setAppActive(true)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                profile.setAppActive(true)
            case .inactive, .background:
                profile.setAppActive(false)
            @unknown default:
                break
            }
        }
    }

    private func openCasino(_ game: GameCasProfSt.CasinoMode) {
        guard profile.isModeUnlocked(game) else {
            lockedAlert = LockedModeAlert(mode: game)
            return
        }

        activeCasino = nil
        Task { @MainActor in
            activeCasino = game
        }
    }
}

private struct LockedModeAlert: Identifiable {
    let id = UUID()
    let mode: GameCasProfSt.CasinoMode
}

private struct CasinoHostView: View {
    let game: GameCasProfSt.CasinoMode
    let onClose: () -> Void

    var body: some View {
        Group {
            switch game {
            case .hot, .lucky:
                GameHotView(game: game, onClose: onClose)
            case .emerald:
                GameEmeraldView(game: game, onClose: onClose)
            case .pharaoh:
                GameEgyptView(game: game, onClose: onClose)
            case .fruit:
                GameFruitView(game: game, onClose: onClose)
            case .poker:
                GamePokerView(game: game, onClose: onClose)
            case .fish:
                GameFishView(game: game, onClose: onClose)
            }
        }
    }
}
