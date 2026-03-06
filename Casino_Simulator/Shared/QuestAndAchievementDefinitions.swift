// Path: Shared/QuestAndAchievementDefinitions.swift

import Foundation

struct QuestDefinition: Identifiable, Equatable {
    let id: String
    let title: String
    let target: Int
    let rewardCoins: Int
}

struct AchievementDefinition: Identifiable, Equatable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let target: Int
    let rewardCoins: Int
}

enum QuestDefinitions {
    static let spins15 = QuestDefinition(
        id: "quest.spins.15",
        title: "Complete 15 spins",
        target: 15,
        rewardCoins: 5_000
    )

    static let playAllGames = QuestDefinition(
        id: "quest.play.all",
        title: "Play all games",
        target: 1,
        rewardCoins: 15_000
    )

    static let earnCoins50k = QuestDefinition(
        id: "quest.earn.50000",
        title: "Earn 50,000 coins total",
        target: 50_000,
        rewardCoins: 30_000
    )

    static let playHot55 = QuestDefinition(
        id: "quest.play.hot.55",
        title: "Play Hot, 55 times",
        target: 55,
        rewardCoins: 25_000
    )

    static let playPharaoh55 = QuestDefinition(
        id: "quest.play.pharaoh.55",
        title: "Play Pharaoh, 55 times",
        target: 55,
        rewardCoins: 25_000
    )

    static let playFavorite25 = QuestDefinition(
        id: "quest.play.favorite.25",
        title: "Play your favorite casino 25 times",
        target: 25,
        rewardCoins: 25_000
    )

    static let breakEven10 = QuestDefinition(
        id: "quest.breakEven.10",
        title: "Finish 10 spins without losing (x1 or more)",
        target: 10,
        rewardCoins: 8_000
    )

    static let x3Wins10 = QuestDefinition(
        id: "quest.x3.10",
        title: "Win x3 or more, 10 times",
        target: 10,
        rewardCoins: 20_000
    )

    static let x10Win1 = QuestDefinition(
        id: "quest.x10.1",
        title: "Win x10 one time",
        target: 1,
        rewardCoins: 35_000
    )

    static let x50Win1 = QuestDefinition(
        id: "quest.x50.1",
        title: "Win x50 one time",
        target: 1,
        rewardCoins: 100_000
    )

    static let spins100 = QuestDefinition(
        id: "quest.spins.100",
        title: "Complete 100 spins",
        target: 100,
        rewardCoins: 18_000
    )

    static let breakEven25 = QuestDefinition(
        id: "quest.breakEven.25",
        title: "Finish 25 spins without losing (x1 or more)",
        target: 25,
        rewardCoins: 18_000
    )

    static let x5Win1 = QuestDefinition(
        id: "quest.x5.1",
        title: "Win x5 one time",
        target: 1,
        rewardCoins: 35_000
    )

    static let x7Win1 = QuestDefinition(
        id: "quest.x7.1",
        title: "Win x7 one time",
        target: 1,
        rewardCoins: 45_000
    )

    static let playPoker25 = QuestDefinition(
        id: "quest.play.poker.25",
        title: "Play Poker 25 hands",
        target: 25,
        rewardCoins: 14_000
    )

    static let playFish25 = QuestDefinition(
        id: "quest.play.fish.25",
        title: "Play Fish 25 times",
        target: 25,
        rewardCoins: 14_000
    )

    static let openApp15 = QuestDefinition(
        id: "quest.open.15",
        title: "Open the app 15 times",
        target: 15,
        rewardCoins: 10_000
    )

    static let streak3 = QuestDefinition(
        id: "quest.streak.3",
        title: "Keep a 3-day streak",
        target: 1,
        rewardCoins: 12_000
    )

    static let level10 = QuestDefinition(
        id: "quest.level.10",
        title: "Reach level 10",
        target: 10,
        rewardCoins: 14_000
    )

    static let claimRewards10 = QuestDefinition(
        id: "quest.claim.10",
        title: "Claim 10 rewards",
        target: 10,
        rewardCoins: 28_000
    )

    static let all: [QuestDefinition] = [
        spins15,
        playAllGames,
        earnCoins50k,
        playHot55,
        playPharaoh55,
        playFavorite25,
        breakEven10,
        x3Wins10,
        x10Win1,
        x50Win1,
        spins100,
        breakEven25,
        x5Win1,
        x7Win1,
        playPoker25,
        playFish25,
        openApp15,
        streak3,
        level10,
        claimRewards10
    ]

    static let byId: [String: QuestDefinition] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}

enum AchievementDefinitions {
    static let dailyStreak5 = AchievementDefinition(
        id: "ach.streak.5",
        icon: "streak",
        title: "Hot Streak",
        subtitle: "Open the app 5 days in a row",
        target: 5,
        rewardCoins: 800
    )

    static let level5 = AchievementDefinition(
        id: "ach.level.5",
        icon: "lvlUp",
        title: "Getting Started",
        subtitle: "Reach level 5",
        target: 5,
        rewardCoins: 1_000
    )

    static let level10 = AchievementDefinition(
        id: "ach.level.10",
        icon: "lvlUp",
        title: "On Your Way",
        subtitle: "Reach level 10",
        target: 10,
        rewardCoins: 2_000
    )

    static let level15 = AchievementDefinition(
        id: "ach.level.15",
        icon: "lvlUp",
        title: "Rising Star",
        subtitle: "Reach level 15",
        target: 15,
        rewardCoins: 3_500
    )

    static let level20 = AchievementDefinition(
        id: "ach.level.20",
        icon: "lvlUp",
        title: "Pro Player",
        subtitle: "Reach level 20",
        target: 20,
        rewardCoins: 5_000
    )

    static let level30 = AchievementDefinition(
        id: "ach.level.30",
        icon: "lvlUp",
        title: "High Roller",
        subtitle: "Reach level 30",
        target: 30,
        rewardCoins: 9_000
    )

    static let level40 = AchievementDefinition(
        id: "ach.level.40",
        icon: "lvlUp",
        title: "Elite",
        subtitle: "Reach level 40",
        target: 40,
        rewardCoins: 13_000
    )

    static let level60 = AchievementDefinition(
        id: "ach.level.60",
        icon: "lvlUp",
        title: "Veteran",
        subtitle: "Reach level 60",
        target: 60,
        rewardCoins: 22_000
    )

    static let level80 = AchievementDefinition(
        id: "ach.level.80",
        icon: "lvlUp",
        title: "Master",
        subtitle: "Reach level 80",
        target: 80,
        rewardCoins: 35_000
    )

    static let level100 = AchievementDefinition(
        id: "ach.level.100",
        icon: "lvlUp",
        title: "Legend",
        subtitle: "Reach level 100",
        target: 100,
        rewardCoins: 50_000
    )

    static let levelMilestones: [AchievementDefinition] = [
        level5, level10, level15, level20, level30, level40, level60, level80, level100
    ]

    static let spins10 = AchievementDefinition(
        id: "ach.spins.10",
        icon: "lvlUp",
        title: "Warm-up",
        subtitle: "Make 10 spins",
        target: 10,
        rewardCoins: 600
    )

    static let spins20 = AchievementDefinition(
        id: "ach.spins.20",
        icon: "lvlUp",
        title: "Getting Momentum",
        subtitle: "Make 20 spins",
        target: 20,
        rewardCoins: 1_200
    )

    static let spins30 = AchievementDefinition(
        id: "ach.spins.30",
        icon: "lvlUp",
        title: "On a Roll",
        subtitle: "Make 30 spins",
        target: 30,
        rewardCoins: 2_000
    )

    static let spins40 = AchievementDefinition(
        id: "ach.spins.40",
        icon: "lvlUp",
        title: "Spin Routine",
        subtitle: "Make 40 spins",
        target: 40,
        rewardCoins: 2_800
    )

    static let spins50 = AchievementDefinition(
        id: "ach.spins.50",
        icon: "lvlUp",
        title: "Half-Hundred",
        subtitle: "Make 50 spins",
        target: 50,
        rewardCoins: 4_000
    )

    static let spins80 = AchievementDefinition(
        id: "ach.spins.80",
        icon: "lvlUp",
        title: "Fast Fingers",
        subtitle: "Make 80 spins",
        target: 80,
        rewardCoins: 6_500
    )

    static let totalSpins100 = AchievementDefinition(
        id: "ach.spins.100",
        icon: "lvlUp",
        title: "Spinner",
        subtitle: "Make 100 spins",
        target: 100,
        rewardCoins: 7_500
    )

    static let spins200 = AchievementDefinition(
        id: "ach.spins.200",
        icon: "lvlUp",
        title: "Spin Machine",
        subtitle: "Make 200 spins",
        target: 200,
        rewardCoins: 15_000
    )

    static let spins250 = AchievementDefinition(
        id: "ach.spins.250",
        icon: "lvlUp",
        title: "Unstoppable",
        subtitle: "Make 250 spins",
        target: 250,
        rewardCoins: 20_000
    )

    static let spins500 = AchievementDefinition(
        id: "ach.spins.500",
        icon: "lvlUp",
        title: "Spin Legend",
        subtitle: "Make 500 spins",
        target: 500,
        rewardCoins: 55_000
    )

    static let spinMilestones: [AchievementDefinition] = [
        spins10, spins20, spins30, spins40, spins50, spins80, totalSpins100, spins200, spins250, spins500
    ]

    static let hotPlays50 = AchievementDefinition(
        id: "ach.hot.50",
        icon: "lvlUp",
        title: "Hot Fan",
        subtitle: "Play Hot 50 times",
        target: 50,
        rewardCoins: 6_000
    )

    static let all: [AchievementDefinition] = [
        dailyStreak5,
        level5, level10, level15, level20, level30, level40, level60, level80, level100,
        spins10, spins20, spins30, spins40, spins50, spins80, totalSpins100, spins200, spins250, spins500,
        hotPlays50
    ]

    static let byId: [String: AchievementDefinition] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}
