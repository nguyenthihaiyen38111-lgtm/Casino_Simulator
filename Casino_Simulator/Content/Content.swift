// Path: Content/Content.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var profile = GameCasProfSt.shared
    @StateObject private var avatarStore = ProfileAvatarStore.shared

    @State private var selectedTab: ProjectClubTabBar.Tab = .lobby
    @State private var activeCasino: GameCasProfSt.CasinoMode?
    @State private var showProfile = false

    private enum Assets {
        static let background = "back_lobby"

        static let tabLobby = "lobby"
        static let tabAchievs = "Achievs"
        static let tabGame = "Game"
        static let tabQuests = "Quests"
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let isCompact = w <= 375

            let sideInset: CGFloat = isCompact ? 22 : 24
            let bottomSafe = proxy.safeAreaInsets.bottom

            let tabLift: CGFloat = isCompact ? 10 : 12
            let tabBottomPad: CGFloat = bottomSafe + tabLift

            let tabHeight = ProjectClubTabBar.preferredHeight(forWidth: w)
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
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .overlay(alignment: .bottom) {
                ProjectClubTabBar(
                    items: [
                        .init(tab: .lobby, icon: Assets.tabLobby, title: "Lobby"),
                        .init(tab: .achievs, icon: Assets.tabAchievs, title: "Achievs"),
                        .init(tab: .game, icon: Assets.tabGame, title: "Game"),
                        .init(tab: .quests, icon: Assets.tabQuests, title: "Quests")
                    ],
                    selected: selectedTab,
                    onSelect: { selectedTab = $0 }
                )
                .padding(.horizontal, sideInset)
                .padding(.bottom, tabBottomPad)
                .allowsHitTesting(true)
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
        }
    }

    private func openCasino(_ game: GameCasProfSt.CasinoMode) {
        activeCasino = nil
        Task { @MainActor in
            activeCasino = game
        }
    }
}

private struct CasinoHostView: View {
    let game: GameCasProfSt.CasinoMode
    let onClose: () -> Void

    var body: some View {
        Group {
            switch game {
            case .hot, .lucky:
                GameHotView(
                    game: game,
                    onClose: onClose
                )

            case .emerald:
                GameEmeraldView(
                    game: game,
                    onClose: onClose
                )

            case .pharaoh:
                GameEgyptView(
                    game: game,
                    onClose: onClose
                )

            case .fruit:
                GameFruitView(
                    game: game,
                    onClose: onClose
                )

            case .poker:
                GamePokerView(
                    game: game,
                    onClose: onClose
                )

            case .fish:
                GameFishView(
                    game: game,
                    onClose: onClose
                )
            }
        }
    }
}
