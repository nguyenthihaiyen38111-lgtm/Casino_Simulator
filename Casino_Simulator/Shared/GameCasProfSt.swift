// Path: Shared/GameCasProfSt.swift

import Foundation
import SwiftUI
import Combine
import UIKit

@MainActor
final class GameCasProfSt: ObservableObject {
    static let shared = GameCasProfSt()

    enum CasinoMode: String, CaseIterable, Codable, Hashable, Identifiable {
        case hot
        case emerald
        case pharaoh
        case fruit
        case poker
        case lucky
        case fish

        static var playableForAllGamesQuest: [CasinoMode] {
            [.hot, .emerald, .pharaoh, .fruit, .poker, .fish]
        }

        var id: String { rawValue }

        var title: String {
            switch self {
            case .hot: return "Hot"
            case .emerald: return "Castle"
            case .pharaoh: return "Pharaoh"
            case .fruit: return "Fruit"
            case .poker: return "Poker"
            case .lucky: return "Lucky"
            case .fish: return "Fish"
            }
        }
    }

    struct SpinResolution: Equatable {
        let mode: CasinoMode
        let stake: Int
        let multiplier: Double
        let payout: Int
        let delta: Int
        let gainedXP: Int
        let rankUps: Int
        let symbols: [SlotSymbol]
        let timestamp: Date
    }

    enum RewardClaimType: String, Codable, Hashable {
        case quest
        case achievement
    }

    struct RewardClaimID: Codable, Hashable {
        let type: RewardClaimType
        let value: String
    }

    struct SaveState: Codable, Equatable {
        var balance: Int
        var rank: Int
        var xp: Int

        var wonTotal: Int
        var lostTotal: Int
        var spinCount: Int

        var modePlays: [CasinoMode: Int]

        var lastDayStamp: Int
        var streakDays: Int
        var launchCount: Int

        var questValues: [String: Int]
        var achievementValues: [String: Int]
        var claimedRewards: Set<RewardClaimID>

        var lastDailyRewardAt: Date?
        var lastTwoHourRewardAt: Date?

        static func initial(at now: Date) -> SaveState {
            SaveState(
                balance: 30_000,
                rank: 1,
                xp: 0,
                wonTotal: 0,
                lostTotal: 0,
                spinCount: 0,
                modePlays: Dictionary(uniqueKeysWithValues: CasinoMode.allCases.map { ($0, 0) }),
                lastDayStamp: GameCasProfSt.makeDayStamp(from: now),
                streakDays: 1,
                launchCount: 0,
                questValues: [:],
                achievementValues: [:],
                claimedRewards: [],
                lastDailyRewardAt: nil,
                lastTwoHourRewardAt: nil
            )
        }
    }

    struct UnlockRequirement: Identifiable, Equatable {
        enum Kind: String, Codable, Hashable {
            case spins
            case coins
            case seconds
            case wins
        }

        let id: String
        let title: String
        let current: Int
        let target: Int
        let kind: Kind

        var isCompleted: Bool { current >= target }

        var fraction: Double {
            guard target > 0 else { return 0 }
            return min(1.0, Double(max(0, current)) / Double(target))
        }
    }

    struct UnlockCardModel: Identifiable, Equatable {
        let id: CasinoMode
        let mode: CasinoMode
        let iconAsset: String
        let title: String
        let subtitle: String
        let rewardAchievementId: String
        let rewardCoins: Int
        let requirements: [UnlockRequirement]
        let progressPercent: Int
        let isUnlocked: Bool
        let isClaimed: Bool
    }

    struct DailyChallengeSnapshot: Codable, Equatable {
        var dayStamp: Int
        var mode: CasinoMode
        var fixedBet: Int
        var spinLimit: Int
        var targetNet: Int
        var rewardCoins: Int

        var spinsUsed: Int
        var netEarned: Int
        var completedAt: Date?
        var claimedAt: Date?

        var isCompleted: Bool { completedAt != nil }
        var isClaimed: Bool { claimedAt != nil }
    }

    private struct UnlockStats: Codable, Equatable {
        var earnedByMode: [CasinoMode: Int]
        var pokerWinCount: Int
        var playSeconds: Int

        static func initial() -> UnlockStats {
            UnlockStats(
                earnedByMode: Dictionary(uniqueKeysWithValues: CasinoMode.allCases.map { ($0, 0) }),
                pokerWinCount: 0,
                playSeconds: 0
            )
        }
    }

    private enum UnlockRules {
        static let castleSpins = 30
        static let castleWin = 30_000

        static let pharaohSpins = 40
        static let pharaohWin = 40_000

        static let fruitSpins = 50
        static let fruitWin = 50_000

        static let pokerPlaySeconds = 5 * 3600
        static let pokerTotalWin = 150_000

        static let fishPokerWins = 30
    }

    @Published private(set) var state: SaveState = SaveState.initial(at: Date())
    @Published private(set) var inventoryEventAssetName: String = "hot_event"
    @Published private(set) var inventoryEventMode: CasinoMode = .hot

    private let persistence = PersistenceBox()
    private let unlockBox = UnlockStatsBox()
    private let dailyChallengeBox = DailyChallengeBox()

    private var unlockStats: UnlockStats = UnlockStats.initial()

    @Published private(set) var dailyChallenge: DailyChallengeSnapshot = DailyChallengeSnapshot(
        dayStamp: GameCasProfSt.makeDayStamp(from: Date()),
        mode: .hot,
        fixedBet: 200,
        spinLimit: 20,
        targetNet: 6_000,
        rewardCoins: 12_000,
        spinsUsed: 0,
        netEarned: 0,
        completedAt: nil,
        claimedAt: nil
    )

    private var didRegisterSessionLaunch = false

    private let dailyRewardValue = 50_000
    private let dailyRewardDelay: TimeInterval = 24 * 60 * 60

    private let twoHourRewardValue = 1_000
    private let twoHourRewardDelay: TimeInterval = 2 * 60 * 60

    private let inventoryRotationInterval: TimeInterval = 5 * 60
    private let gameplayActiveWindow: TimeInterval = 90

    private var inventoryTimer: AnyCancellable?
    private var lastGameplayActivityAt: Date = .distantPast
    private var lastInventoryRotationAt: Date = .distantPast

    private var isAppActive: Bool = true
    private var playtimeLastTickAt: Date = .distantPast
    private var playtimeAccumSinceSave: Int = 0
    private let playtimeSaveIntervalSeconds: Int = 15

    private var adminUnlockAllGames: Bool {
        get { UserDefaults.standard.bool(forKey: "admin_unlock_all_games") }
        set { UserDefaults.standard.set(newValue, forKey: "admin_unlock_all_games") }
    }

    var coins: Int { state.balance }
    var level: Int { state.rank }
    var xpInLevel: Int { state.xp }
    var xpToNextLevel: Int { Self.requiredXP(for: state.rank) }

    var totalWon: Int { state.wonTotal }
    var totalLost: Int { state.lostTotal }
    var totalSpins: Int { state.spinCount }
    var loginStreak: Int { state.streakDays }
    var totalAppLaunches: Int { state.launchCount }

    var totalPlaySeconds: Int { unlockStats.playSeconds }
    var pokerWinCount: Int { unlockStats.pokerWinCount }

    func earnedCoins(for mode: CasinoMode) -> Int {
        unlockStats.earnedByMode[mode] ?? 0
    }

    var favoriteCasino: CasinoMode {
        let sorted = state.modePlays.sorted { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key.rawValue < rhs.key.rawValue }
            return lhs.value > rhs.value
        }
        return sorted.first?.key ?? .hot
    }

    private init() {
        let now = Date()

        if let saved = persistence.read() {
            state = saved
        } else {
            state = SaveState.initial(at: now)
            persistence.write(state)
        }

        unlockStats = unlockBox.read() ?? UnlockStats.initial()

        let today = Self.makeDayStamp(from: now)
        dailyChallenge = dailyChallengeBox.read() ?? Self.makeDailyChallenge(
            dayStamp: today,
            unlockedModes: [.hot]
        )

        setupInventoryEvents(now: now)

        refreshDailyChallengeIfNeeded(now: now)
        registerAppLaunch(now: now)
        prepareProgressStorage()
        syncUnlockAchievements()
    }

    func setAppActive(_ active: Bool, now: Date = Date()) {
        if active {
            if !isAppActive {
                isAppActive = true
                playtimeLastTickAt = now
                playtimeAccumSinceSave = 0
            }
        } else {
            flushPlaytime(now: now)
            isAppActive = false
        }
    }

    func formattedPlaytime(seconds: Int) -> String {
        let total = max(0, seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    func isModeUnlocked(_ mode: CasinoMode) -> Bool {
        if adminUnlockAllGames {
            return true
        }

        switch mode {
        case .hot, .lucky:
            return true
        case .emerald:
            return castleUnlocked
        case .pharaoh:
            return pharaohUnlocked
        case .fruit:
            return fruitUnlocked
        case .poker:
            return pokerUnlocked
        case .fish:
            return fishUnlocked
        }
    }

    var unlockCards: [UnlockCardModel] {
        [unlockCardCastle, unlockCardPharaoh, unlockCardFruit, unlockCardPoker, unlockCardFish]
    }

    func unlockMessage(for mode: CasinoMode) -> String {
        if isModeUnlocked(mode) {
            return "\(mode.title) is already unlocked."
        }

        guard let card = unlockCards.first(where: { $0.mode == mode }) else {
            return "This mode is locked. Complete all requirements to unlock it."
        }

        var lines: [String] = []
        lines.append("\(mode.title) is locked.")
        lines.append("")
        lines.append("Complete all requirements:")

        for req in card.requirements {
            switch req.kind {
            case .seconds:
                let currentText = formattedPlaytime(seconds: req.current)
                let targetText = formattedPlaytime(seconds: req.target)
                lines.append("— \(req.title): \(currentText) / \(targetText)")
            default:
                lines.append("— \(req.title): \(formatNumber(req.current)) / \(formatNumber(req.target))")
            }
        }

        lines.append("")
        lines.append("Progress: \(card.progressPercent)%")
        return lines.joined(separator: "\n")
    }

    func applyAppOpen(now: Date = Date()) {
        registerAppLaunch(now: now)
    }

    func achievementProgressValue(for id: String) -> Int {
        state.achievementValues[id] ?? 0
    }

    func questProgressValue(for id: String) -> Int {
        state.questValues[id] ?? 0
    }

    func registerAppLaunch(now: Date = Date()) {
        var hasChanges = false

        if !didRegisterSessionLaunch {
            didRegisterSessionLaunch = true
            state.launchCount += 1
            hasChanges = true
        }

        let todayStamp = Self.makeDayStamp(from: now)
        if state.lastDayStamp != todayStamp {
            let expectedNext = state.lastDayStamp + 1
            if todayStamp == expectedNext {
                state.streakDays = max(1, state.streakDays + 1)
            } else {
                state.streakDays = 1
            }

            state.lastDayStamp = todayStamp
            if let def = AchievementDefinitions.byId["ach.streak.5"] {
                state.achievementValues[def.id] = state.streakDays
            }
            hasChanges = true
        }

        if refreshDailyChallengeIfNeeded(now: now) {
            hasChanges = true
        }

        if hasChanges {
            syncDerivedQuests()
            syncDerivedAchievements()
            syncUnlockAchievements()
            saveChanges()
        }
    }

    func claimDailyBonus(now: Date = Date()) {
        guard canClaimDailyBonus else { return }
        state.balance += dailyRewardValue
        state.lastDailyRewardAt = now
        saveChanges()
    }

    func claimTwoHourBonus(now: Date = Date()) {
        guard canClaimTwoHourBonus else { return }
        state.balance += twoHourRewardValue
        state.lastTwoHourRewardAt = now
        saveChanges()
    }

    var canClaimDailyBonus: Bool {
        dailyBonusRemainingSeconds <= 0
    }

    var dailyBonusRemainingSeconds: Int {
        guard let last = state.lastDailyRewardAt else { return 0 }
        let nextDate = last.addingTimeInterval(dailyRewardDelay)
        let value = Int(ceil(nextDate.timeIntervalSince(Date())))
        return max(0, value)
    }

    var dailyBonusRemainingText: String {
        let total = dailyBonusRemainingSeconds
        if total <= 0 { return "READY" }
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var canClaimTwoHourBonus: Bool {
        twoHourBonusRemainingSeconds <= 0
    }

    var twoHourBonusRemainingSeconds: Int {
        guard let last = state.lastTwoHourRewardAt else { return 0 }
        let nextDate = last.addingTimeInterval(twoHourRewardDelay)
        let value = Int(ceil(nextDate.timeIntervalSince(Date())))
        return max(0, value)
    }

    var twoHourBonusRemainingText: String {
        let total = twoHourBonusRemainingSeconds
        if total <= 0 { return "READY" }
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func canAffordBet(_ bet: Int, minBet: Int) -> Bool {
        let normalized = max(minBet, bet)
        return normalized <= state.balance
    }

    func normalizedBet(_ bet: Int, minBet: Int) -> Int {
        let lowerBounded = max(minBet, bet)
        return min(lowerBounded, max(minBet, state.balance))
    }

    func spin(mode: CasinoMode, bet: Int, minBet: Int = 100) -> SpinResolution? {
        guard isModeUnlocked(mode) else { return nil }

        let finalBet = normalizedBet(bet, minBet: minBet)
        guard finalBet >= minBet, finalBet <= state.balance else { return nil }

        let now = Date()
        noteGameplayActivity(now: now)
        _ = refreshDailyChallengeIfNeeded(now: now)

        let roll = SlotMath.rollOutcome(bet: finalBet)

        state.balance -= finalBet
        state.balance += roll.payout

        state.spinCount += 1
        state.modePlays[mode, default: 0] += 1

        if roll.net >= 0 {
            state.wonTotal += roll.net
        } else {
            state.lostTotal += abs(roll.net)
        }

        if roll.net > 0 {
            unlockStats.earnedByMode[mode, default: 0] += roll.net
            unlockBox.write(unlockStats)
        }

        applyDailyChallengeProgressIfNeeded(mode: mode, bet: finalBet, netDelta: roll.net, now: now)

        noteCasinoPlayedForFavoriteQuest(mode: mode)
        advanceQuestProgressAfterWin(multiplier: roll.multiplier)

        let xp = Self.calculateXP(for: finalBet, multiplier: roll.multiplier)
        _ = applyXP(xp)

        syncDerivedQuests()
        syncDerivedAchievements()
        syncUnlockAchievements()

        saveChanges()

        return SpinResolution(
            mode: mode,
            stake: finalBet,
            multiplier: roll.multiplier,
            payout: roll.payout,
            delta: roll.net,
            gainedXP: xp,
            rankUps: 0,
            symbols: roll.finalWindow,
            timestamp: now
        )
    }

    func claimDailyChallengeReward(now: Date = Date()) {
        _ = refreshDailyChallengeIfNeeded(now: now)
        guard dailyChallenge.isCompleted, !dailyChallenge.isClaimed else { return }

        state.balance += max(0, dailyChallenge.rewardCoins)
        dailyChallenge.claimedAt = now
        dailyChallengeBox.write(dailyChallenge)
        saveChanges()
    }

    func isClaimed(_ type: RewardClaimType, id: String) -> Bool {
        state.claimedRewards.contains(RewardClaimID(type: type, value: id))
    }

    func claimQuest(id: String) {
        guard let definition = QuestDefinitions.byId[id] else { return }
        guard !isClaimed(.quest, id: id) else { return }

        let currentValue = state.questValues[id] ?? 0
        guard currentValue >= definition.target else { return }

        state.balance += definition.rewardCoins
        state.claimedRewards.insert(RewardClaimID(type: .quest, value: id))

        syncDerivedQuests()
        saveChanges()
    }

    func claimAchievement(id: String) {
        guard let definition = AchievementDefinitions.byId[id] else { return }
        guard !isClaimed(.achievement, id: id) else { return }

        let currentValue = state.achievementValues[id] ?? 0
        guard currentValue >= definition.target else { return }

        state.balance += definition.rewardCoins
        state.claimedRewards.insert(RewardClaimID(type: .achievement, value: id))

        syncDerivedQuests()
        syncDerivedAchievements()
        syncUnlockAchievements()
        saveChanges()
    }

    func unlockAllGamesForTesting() {
        adminUnlockAllGames = true
        objectWillChange.send()
    }

    func resetTestingGameUnlocks() {
        adminUnlockAllGames = false
        objectWillChange.send()
    }

    func resetAllProgress() {
        let now = Date()
        adminUnlockAllGames = false
        state = SaveState.initial(at: now)
        didRegisterSessionLaunch = false
        registerAppLaunch(now: now)
        prepareProgressStorage()
        rotateInventoryEvent(now: now, force: true)

        unlockStats = UnlockStats.initial()
        unlockBox.write(unlockStats)

        let today = Self.makeDayStamp(from: now)
        dailyChallenge = Self.makeDailyChallenge(dayStamp: today, unlockedModes: [.hot])
        dailyChallengeBox.write(dailyChallenge)

        syncUnlockAchievements()
        saveChanges()
    }

    func spendPokerBetImmediately(_ amount: Int) -> Bool {
        guard isModeUnlocked(.poker) else { return false }

        let safeAmount = max(0, amount)
        guard safeAmount > 0 else { return false }
        guard state.balance >= safeAmount else { return false }

        noteGameplayActivity(now: Date())

        state.balance -= safeAmount
        saveChanges()
        return true
    }

    func applyPokerHandDelta(_ delta: Int) {
        guard isModeUnlocked(.poker) else { return }

        let now = Date()
        noteGameplayActivity(now: now)
        _ = refreshDailyChallengeIfNeeded(now: now)

        if delta == 0 {
            state.modePlays[.poker, default: 0] += 1
            noteCasinoPlayedForFavoriteQuest(mode: .poker)
            syncDerivedQuests()
            syncDerivedAchievements()
            syncUnlockAchievements()
            saveChanges()
            return
        }

        if delta > 0 {
            state.balance += delta
            state.wonTotal += delta

            unlockStats.earnedByMode[.poker, default: 0] += delta
            unlockStats.pokerWinCount += 1
            unlockBox.write(unlockStats)
        } else {
            let loss = abs(delta)
            state.balance = max(0, state.balance - loss)
            state.lostTotal += loss
        }

        state.modePlays[.poker, default: 0] += 1
        noteCasinoPlayedForFavoriteQuest(mode: .poker)

        applyDailyChallengeProgressIfNeeded(mode: .poker, bet: 0, netDelta: delta, now: now)

        syncDerivedQuests()
        syncDerivedAchievements()
        syncUnlockAchievements()
        saveChanges()
    }

    private func applyDailyChallengeProgressIfNeeded(mode: CasinoMode, bet: Int, netDelta: Int, now: Date) {
        guard dailyChallenge.dayStamp == Self.makeDayStamp(from: now) else { return }
        guard !dailyChallenge.isCompleted else { return }
        guard dailyChallenge.mode == mode else { return }
        guard mode != .poker else { return }
        guard bet == dailyChallenge.fixedBet else { return }

        dailyChallenge.spinsUsed += 1
        dailyChallenge.netEarned += netDelta

        let hitTarget = dailyChallenge.netEarned >= dailyChallenge.targetNet
        let hitLimit = dailyChallenge.spinsUsed >= max(1, dailyChallenge.spinLimit)

        if hitTarget || hitLimit {
            dailyChallenge.completedAt = now
        }

        dailyChallengeBox.write(dailyChallenge)
    }

    private func refreshDailyChallengeIfNeeded(now: Date) -> Bool {
        let today = Self.makeDayStamp(from: now)
        if dailyChallenge.dayStamp != today {
            let unlocked = unlockedDailyChallengeModes()
            dailyChallenge = Self.makeDailyChallenge(dayStamp: today, unlockedModes: unlocked)
            dailyChallengeBox.write(dailyChallenge)
            return true
        }

        if dailyChallenge.mode != .hot && !isModeUnlocked(dailyChallenge.mode) {
            let unlocked = unlockedDailyChallengeModes()
            dailyChallenge = Self.makeDailyChallenge(dayStamp: today, unlockedModes: unlocked)
            dailyChallengeBox.write(dailyChallenge)
            return true
        }

        return false
    }

    private func unlockedDailyChallengeModes() -> [CasinoMode] {
        let pool: [CasinoMode] = [.hot, .emerald, .pharaoh, .fruit, .fish]
        let unlocked = pool.filter { isModeUnlocked($0) }
        return unlocked.isEmpty ? [.hot] : unlocked
    }

    private static func makeDailyChallenge(dayStamp: Int, unlockedModes: [CasinoMode]) -> DailyChallengeSnapshot {
        var rng = SeededRNG(seed: UInt64(bitPattern: Int64(dayStamp)) ^ 0xC0FFEE_BADC0DE)

        let modes = unlockedModes.isEmpty ? [.hot] : unlockedModes
        let mode = modes[rng.nextInt(modes.count)]

        let betOptions = [100, 200, 300, 500, 800]
        let fixedBet = betOptions[rng.nextInt(betOptions.count)]

        let spinLimitOptions = [12, 15, 18, 20, 24]
        let spinLimit = spinLimitOptions[rng.nextInt(spinLimitOptions.count)]

        let targetNet = max(2_000, min(30_000, fixedBet * (8 + rng.nextInt(10))))
        let rewardCoins = max(3_000, min(60_000, Int(Double(targetNet) * (1.6 + (Double(rng.nextInt(30)) / 100.0)))))

        return DailyChallengeSnapshot(
            dayStamp: dayStamp,
            mode: mode,
            fixedBet: fixedBet,
            spinLimit: spinLimit,
            targetNet: targetNet,
            rewardCoins: rewardCoins,
            spinsUsed: 0,
            netEarned: 0,
            completedAt: nil,
            claimedAt: nil
        )
    }

    private func applyXP(_ amount: Int) -> Int {
        guard amount > 0 else { return 0 }

        var rankUps = 0
        state.xp += amount

        while state.xp >= Self.requiredXP(for: state.rank) {
            state.xp -= Self.requiredXP(for: state.rank)
            state.rank += 1
            rankUps += 1
        }

        return rankUps
    }

    private func prepareProgressStorage() {
        for quest in QuestDefinitions.all where state.questValues[quest.id] == nil {
            state.questValues[quest.id] = 0
        }

        for achievement in AchievementDefinitions.all where state.achievementValues[achievement.id] == nil {
            state.achievementValues[achievement.id] = 0
        }

        syncDerivedQuests()
        syncDerivedAchievements()
    }

    private func noteCasinoPlayedForFavoriteQuest(mode: CasinoMode) {
        if mode == favoriteCasino {
            state.questValues[QuestDefinitions.playFavorite25.id, default: 0] += 1
        }
    }

    private func advanceQuestProgressAfterWin(multiplier: Double) {
        if multiplier >= 1.0 {
            state.questValues[QuestDefinitions.breakEven10.id, default: 0] += 1
            state.questValues[QuestDefinitions.breakEven25.id, default: 0] += 1
        }

        if multiplier >= 3.0 {
            state.questValues[QuestDefinitions.x3Wins10.id, default: 0] += 1
        }

        if multiplier >= 5.0 {
            state.questValues[QuestDefinitions.x5Win1.id] = 1
        }

        if multiplier >= 7.0 {
            state.questValues[QuestDefinitions.x7Win1.id] = 1
        }

        if multiplier >= 10.0 {
            state.questValues[QuestDefinitions.x10Win1.id] = 1
        }

        if multiplier >= 50.0 {
            state.questValues[QuestDefinitions.x50Win1.id] = 1
        }
    }

    private func syncDerivedAchievements() {
        if let streak = AchievementDefinitions.byId["ach.streak.5"] {
            state.achievementValues[streak.id] = max(state.achievementValues[streak.id] ?? 0, state.streakDays)
        }

        for milestone in AchievementDefinitions.levelMilestones {
            state.achievementValues[milestone.id] = max(state.achievementValues[milestone.id] ?? 0, state.rank)
        }

        for milestone in AchievementDefinitions.spinMilestones {
            state.achievementValues[milestone.id] = max(state.achievementValues[milestone.id] ?? 0, state.spinCount)
        }

        if let hotPlays50 = AchievementDefinitions.byId["ach.hot.50"] {
            let plays = state.modePlays[.hot, default: 0]
            state.achievementValues[hotPlays50.id] = max(state.achievementValues[hotPlays50.id] ?? 0, plays)
        }
    }

    private func syncUnlockAchievements() {
        if AchievementDefinitions.byId[AchievementDefinitions.unlockCastle.id] != nil {
            state.achievementValues[AchievementDefinitions.unlockCastle.id] = max(state.achievementValues[AchievementDefinitions.unlockCastle.id] ?? 0, unlockCardCastle.progressPercent)
        }
        if AchievementDefinitions.byId[AchievementDefinitions.unlockPharaoh.id] != nil {
            state.achievementValues[AchievementDefinitions.unlockPharaoh.id] = max(state.achievementValues[AchievementDefinitions.unlockPharaoh.id] ?? 0, unlockCardPharaoh.progressPercent)
        }
        if AchievementDefinitions.byId[AchievementDefinitions.unlockFruit.id] != nil {
            state.achievementValues[AchievementDefinitions.unlockFruit.id] = max(state.achievementValues[AchievementDefinitions.unlockFruit.id] ?? 0, unlockCardFruit.progressPercent)
        }
        if AchievementDefinitions.byId[AchievementDefinitions.unlockPoker.id] != nil {
            state.achievementValues[AchievementDefinitions.unlockPoker.id] = max(state.achievementValues[AchievementDefinitions.unlockPoker.id] ?? 0, unlockCardPoker.progressPercent)
        }
        if AchievementDefinitions.byId[AchievementDefinitions.unlockFish.id] != nil {
            state.achievementValues[AchievementDefinitions.unlockFish.id] = max(state.achievementValues[AchievementDefinitions.unlockFish.id] ?? 0, unlockCardFish.progressPercent)
        }
    }

    private func syncDerivedQuests() {
        setQuestProgressMonotonic(id: QuestDefinitions.earnCoins50k.id, computed: state.wonTotal, target: QuestDefinitions.earnCoins50k.target)
        setQuestProgressMonotonic(id: QuestDefinitions.spins15.id, computed: state.spinCount, target: QuestDefinitions.spins15.target)
        setQuestProgressMonotonic(id: QuestDefinitions.spins100.id, computed: state.spinCount, target: QuestDefinitions.spins100.target)

        setQuestProgressMonotonic(id: QuestDefinitions.playHot55.id, computed: state.modePlays[.hot, default: 0], target: QuestDefinitions.playHot55.target)
        setQuestProgressMonotonic(id: QuestDefinitions.playPharaoh55.id, computed: state.modePlays[.pharaoh, default: 0], target: QuestDefinitions.playPharaoh55.target)
        setQuestProgressMonotonic(id: QuestDefinitions.playPoker25.id, computed: state.modePlays[.poker, default: 0], target: QuestDefinitions.playPoker25.target)
        setQuestProgressMonotonic(id: QuestDefinitions.playFish25.id, computed: state.modePlays[.fish, default: 0], target: QuestDefinitions.playFish25.target)

        setQuestProgressMonotonic(id: QuestDefinitions.openApp15.id, computed: state.launchCount, target: QuestDefinitions.openApp15.target)
        setQuestProgressMonotonic(id: QuestDefinitions.level10.id, computed: state.rank, target: QuestDefinitions.level10.target)
        setQuestProgressMonotonic(id: QuestDefinitions.claimRewards10.id, computed: state.claimedRewards.count, target: QuestDefinitions.claimRewards10.target)

        let streakDone = state.streakDays >= 3 ? 1 : 0
        state.questValues[QuestDefinitions.streak3.id] = max(state.questValues[QuestDefinitions.streak3.id] ?? 0, streakDone)

        let playedEverything = CasinoMode.playableForAllGamesQuest.allSatisfy { state.modePlays[$0, default: 0] > 0 }
        let allGamesValue = playedEverything ? QuestDefinitions.playAllGames.target : 0
        state.questValues[QuestDefinitions.playAllGames.id] = max(state.questValues[QuestDefinitions.playAllGames.id] ?? 0, allGamesValue)

        for quest in QuestDefinitions.all where state.questValues[quest.id] == nil {
            state.questValues[quest.id] = 0
        }
    }

    private func setQuestProgressMonotonic(id: String, computed: Int, target: Int) {
        let clamped = min(max(0, computed), target)
        state.questValues[id] = max(state.questValues[id] ?? 0, clamped)
    }

    private func setupInventoryEvents(now: Date) {
        rotateInventoryEvent(now: now, force: true)
        startInventoryTimerIfNeeded()
    }

    private func startInventoryTimerIfNeeded() {
        guard inventoryTimer == nil else { return }

        inventoryTimer = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self else { return }
                self.tickPlaytime(now: now)
                self.tickInventoryRotation(now: now)
            }
    }

    private func noteGameplayActivity(now: Date) {
        lastGameplayActivityAt = now
    }

    private func tickPlaytime(now: Date) {
        guard isAppActive else { return }

        if playtimeLastTickAt == .distantPast {
            playtimeLastTickAt = now
            return
        }

        let delta = now.timeIntervalSince(playtimeLastTickAt)
        guard delta > 0 else { return }

        let seconds = Int(floor(delta))
        guard seconds > 0 else { return }

        playtimeLastTickAt = now
        unlockStats.playSeconds += seconds
        playtimeAccumSinceSave += seconds

        if playtimeAccumSinceSave >= playtimeSaveIntervalSeconds {
            playtimeAccumSinceSave = 0
            unlockBox.write(unlockStats)
            syncUnlockAchievements()
            saveChanges()
        }
    }

    private func flushPlaytime(now: Date) {
        guard isAppActive else { return }
        guard playtimeLastTickAt != .distantPast else { return }

        let delta = now.timeIntervalSince(playtimeLastTickAt)
        if delta > 0 {
            let seconds = Int(floor(delta))
            if seconds > 0 {
                unlockStats.playSeconds += seconds
            }
        }

        playtimeLastTickAt = .distantPast
        playtimeAccumSinceSave = 0
        unlockBox.write(unlockStats)
        syncUnlockAchievements()
        saveChanges()
    }

    private func tickInventoryRotation(now: Date) {
        let isPlayingNow = now.timeIntervalSince(lastGameplayActivityAt) <= gameplayActiveWindow
        guard isPlayingNow else { return }

        if lastInventoryRotationAt == .distantPast {
            rotateInventoryEvent(now: now, force: true)
            return
        }

        let elapsed = now.timeIntervalSince(lastInventoryRotationAt)
        guard elapsed >= inventoryRotationInterval else { return }
        rotateInventoryEvent(now: now, force: false)
    }

    private func rotateInventoryEvent(now: Date, force: Bool) {
        let pool = availableInventoryEventPool()
        guard !pool.isEmpty else {
            inventoryEventAssetName = "hot_event"
            inventoryEventMode = .hot
            lastInventoryRotationAt = now
            return
        }

        if !force, pool.count > 1 {
            let filtered = pool.filter { $0.asset != inventoryEventAssetName }
            if let picked = filtered.randomElement() {
                inventoryEventAssetName = picked.asset
                inventoryEventMode = picked.mode
                lastInventoryRotationAt = now
                return
            }
        }

        let picked = pool.randomElement() ?? pool[0]
        inventoryEventAssetName = picked.asset
        inventoryEventMode = picked.mode
        lastInventoryRotationAt = now
    }

    private func availableInventoryEventPool() -> [(asset: String, mode: CasinoMode)] {
        let candidates: [(String, CasinoMode)] = [
            ("hot_event", .hot),
            ("fruit_event", .fruit),
            ("pharaoh_event", .pharaoh),
            ("poker_event", .poker),

            ("castle_event", .emerald),
            ("emerald_event", .emerald),

            ("fish_event", .fish),
            ("lucky_event", .fish)
        ]

        var seen = Set<String>()
        var result: [(asset: String, mode: CasinoMode)] = []

        for (asset, mode) in candidates {
            guard !seen.contains(asset) else { continue }
            seen.insert(asset)
            if UIImage(named: asset) != nil {
                result.append((asset: asset, mode: mode))
            }
        }

        return result
    }

    private func saveChanges() {
        persistence.write(state)
        objectWillChange.send()
    }

    static func requiredXP(for level: Int) -> Int {
        let safeLevel = max(1, level)
        return 100 + (safeLevel - 1) * 200
    }

    static func calculateXP(for bet: Int, multiplier: Double) -> Int {
        guard multiplier >= 1.5 else { return 0 }

        let baseXP = 10
        let stakeBonus = min(40, max(0, bet / 250))
        let multiplierBonus: Int

        if multiplier >= 50 {
            multiplierBonus = 140
        } else if multiplier >= 10 {
            multiplierBonus = 70
        } else if multiplier >= 3 {
            multiplierBonus = 25
        } else {
            multiplierBonus = 12
        }

        return baseXP + stakeBonus + multiplierBonus
    }

    static func makeDayStamp(from date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let dayStart = calendar.startOfDay(for: date)
        return Int(dayStart.timeIntervalSince1970 / 86_400)
    }

    private func formatNumber(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private var castleUnlocked: Bool {
        let hotSpins = state.modePlays[.hot, default: 0]
        let hotEarn = earnedCoins(for: .hot)
        return hotSpins >= UnlockRules.castleSpins && hotEarn >= UnlockRules.castleWin
    }

    private var pharaohUnlocked: Bool {
        guard castleUnlocked else { return false }
        let spins = state.modePlays[.emerald, default: 0]
        let earn = earnedCoins(for: .emerald)
        return spins >= UnlockRules.pharaohSpins && earn >= UnlockRules.pharaohWin
    }

    private var fruitUnlocked: Bool {
        guard pharaohUnlocked else { return false }
        let spins = state.modePlays[.pharaoh, default: 0]
        let earn = earnedCoins(for: .pharaoh)
        return spins >= UnlockRules.fruitSpins && earn >= UnlockRules.fruitWin
    }

    private var pokerUnlocked: Bool {
        guard fruitUnlocked else { return false }
        let playOk = unlockStats.playSeconds >= UnlockRules.pokerPlaySeconds
        let totalEarn = earnedCoins(for: .hot) + earnedCoins(for: .emerald) + earnedCoins(for: .pharaoh) + earnedCoins(for: .fruit)
        let winOk = totalEarn >= UnlockRules.pokerTotalWin
        return playOk && winOk
    }

    private var fishUnlocked: Bool {
        guard pokerUnlocked else { return false }
        return unlockStats.pokerWinCount >= UnlockRules.fishPokerWins
    }

    private var unlockCardCastle: UnlockCardModel {
        let hotSpins = state.modePlays[.hot, default: 0]
        let hotEarn = earnedCoins(for: .hot)

        let req1 = UnlockRequirement(id: "hot.spins", title: "Hot spins", current: hotSpins, target: UnlockRules.castleSpins, kind: .spins)
        let req2 = UnlockRequirement(id: "hot.win", title: "Hot wins", current: hotEarn, target: UnlockRules.castleWin, kind: .coins)

        let progress = min(req1.fraction, req2.fraction)
        let percent = Int(floor(progress * 100.0))
        let achievementId = AchievementDefinitions.unlockCastle.id

        return UnlockCardModel(
            id: .emerald,
            mode: .emerald,
            iconAsset: "castle",
            title: "Unlock Castle",
            subtitle: "Complete Hot goals to access Castle",
            rewardAchievementId: achievementId,
            rewardCoins: AchievementDefinitions.unlockCastle.rewardCoins,
            requirements: [req1, req2],
            progressPercent: min(100, max(0, percent)),
            isUnlocked: percent >= 100,
            isClaimed: isClaimed(.achievement, id: achievementId)
        )
    }

    private var unlockCardPharaoh: UnlockCardModel {
        let spins = state.modePlays[.emerald, default: 0]
        let earn = earnedCoins(for: .emerald)

        let req1 = UnlockRequirement(id: "castle.spins", title: "Castle spins", current: spins, target: UnlockRules.pharaohSpins, kind: .spins)
        let req2 = UnlockRequirement(id: "castle.win", title: "Castle wins", current: earn, target: UnlockRules.pharaohWin, kind: .coins)

        let progress = castleUnlocked ? min(req1.fraction, req2.fraction) : 0
        let percent = Int(floor(progress * 100.0))
        let achievementId = AchievementDefinitions.unlockPharaoh.id

        return UnlockCardModel(
            id: .pharaoh,
            mode: .pharaoh,
            iconAsset: "pharaoh",
            title: "Unlock Pharaoh",
            subtitle: "Complete Castle goals to access Pharaoh",
            rewardAchievementId: achievementId,
            rewardCoins: AchievementDefinitions.unlockPharaoh.rewardCoins,
            requirements: [req1, req2],
            progressPercent: pharaohUnlocked ? 100 : min(100, max(0, percent)),
            isUnlocked: pharaohUnlocked,
            isClaimed: isClaimed(.achievement, id: achievementId)
        )
    }

    private var unlockCardFruit: UnlockCardModel {
        let spins = state.modePlays[.pharaoh, default: 0]
        let earn = earnedCoins(for: .pharaoh)

        let req1 = UnlockRequirement(id: "pharaoh.spins", title: "Pharaoh spins", current: spins, target: UnlockRules.fruitSpins, kind: .spins)
        let req2 = UnlockRequirement(id: "pharaoh.win", title: "Pharaoh wins", current: earn, target: UnlockRules.fruitWin, kind: .coins)

        let progress = pharaohUnlocked ? min(req1.fraction, req2.fraction) : 0
        let percent = Int(floor(progress * 100.0))
        let achievementId = AchievementDefinitions.unlockFruit.id

        return UnlockCardModel(
            id: .fruit,
            mode: .fruit,
            iconAsset: "fruit",
            title: "Unlock Fruit",
            subtitle: "Complete Pharaoh goals to access Fruit",
            rewardAchievementId: achievementId,
            rewardCoins: AchievementDefinitions.unlockFruit.rewardCoins,
            requirements: [req1, req2],
            progressPercent: fruitUnlocked ? 100 : min(100, max(0, percent)),
            isUnlocked: fruitUnlocked,
            isClaimed: isClaimed(.achievement, id: achievementId)
        )
    }

    private var unlockCardPoker: UnlockCardModel {
        let totalEarn = earnedCoins(for: .hot) + earnedCoins(for: .emerald) + earnedCoins(for: .pharaoh) + earnedCoins(for: .fruit)
        let play = unlockStats.playSeconds

        let req1 = UnlockRequirement(id: "playtime", title: "Playtime", current: play, target: UnlockRules.pokerPlaySeconds, kind: .seconds)
        let req2 = UnlockRequirement(id: "all.win", title: "Total wins", current: totalEarn, target: UnlockRules.pokerTotalWin, kind: .coins)

        let progress = fruitUnlocked ? min(req1.fraction, req2.fraction) : 0
        let percent = Int(floor(progress * 100.0))
        let achievementId = AchievementDefinitions.unlockPoker.id

        return UnlockCardModel(
            id: .poker,
            mode: .poker,
            iconAsset: "poker",
            title: "Unlock Poker",
            subtitle: "Play longer and win big across slots",
            rewardAchievementId: achievementId,
            rewardCoins: AchievementDefinitions.unlockPoker.rewardCoins,
            requirements: [req1, req2],
            progressPercent: pokerUnlocked ? 100 : min(100, max(0, percent)),
            isUnlocked: pokerUnlocked,
            isClaimed: isClaimed(.achievement, id: achievementId)
        )
    }

    private var unlockCardFish: UnlockCardModel {
        let wins = unlockStats.pokerWinCount
        let req1 = UnlockRequirement(id: "poker.wins", title: "Poker wins", current: wins, target: UnlockRules.fishPokerWins, kind: .wins)

        let progress = pokerUnlocked ? req1.fraction : 0
        let percent = Int(floor(progress * 100.0))
        let achievementId = AchievementDefinitions.unlockFish.id

        return UnlockCardModel(
            id: .fish,
            mode: .fish,
            iconAsset: "lucky",
            title: "Unlock Fish",
            subtitle: "Win Poker hands to access Fish",
            rewardAchievementId: achievementId,
            rewardCoins: AchievementDefinitions.unlockFish.rewardCoins,
            requirements: [req1],
            progressPercent: fishUnlocked ? 100 : min(100, max(0, percent)),
            isUnlocked: fishUnlocked,
            isClaimed: isClaimed(.achievement, id: achievementId)
        )
    }

    private struct SeededRNG {
        private(set) var state: UInt64

        init(seed: UInt64) {
            self.state = seed == 0 ? 0xA1B2C3D4E5F60789 : seed
        }

        mutating func next() -> UInt64 {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return state
        }

        mutating func nextInt(_ upperBound: Int) -> Int {
            guard upperBound > 0 else { return 0 }
            return Int(next() % UInt64(upperBound))
        }
    }

    private final class PersistenceBox {
        private let storageKey = "casino_simulator.cas.prof.state.v3"
        private let legacyKeys = ["project.cas.prof.state.v3", "projectx.cas.prof.state.v3"]

        func read() -> SaveState? {
            if let data = UserDefaults.standard.data(forKey: storageKey),
               let decoded = try? JSONDecoder().decode(SaveState.self, from: data) {
                return decoded
            }

            for key in legacyKeys {
                if let data = UserDefaults.standard.data(forKey: key),
                   let decoded = try? JSONDecoder().decode(SaveState.self, from: data) {
                    UserDefaults.standard.set(data, forKey: storageKey)
                    return decoded
                }
            }

            return nil
        }

        func write(_ value: SaveState) {
            guard let data = try? JSONEncoder().encode(value) else { return }
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private final class UnlockStatsBox {
        private let storageKey = "casino_simulator.unlock.stats.v1"
        private let legacyKeys = ["project.unlock.stats.v1", "projectx.unlock.stats.v1"]

        func read() -> UnlockStats? {
            if let data = UserDefaults.standard.data(forKey: storageKey),
               let decoded = try? JSONDecoder().decode(UnlockStats.self, from: data) {
                return decoded
            }

            for key in legacyKeys {
                if let data = UserDefaults.standard.data(forKey: key),
                   let decoded = try? JSONDecoder().decode(UnlockStats.self, from: data) {
                    UserDefaults.standard.set(data, forKey: storageKey)
                    return decoded
                }
            }

            return nil
        }

        func write(_ value: UnlockStats) {
            guard let data = try? JSONEncoder().encode(value) else { return }
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private final class DailyChallengeBox {
        private let storageKey = "casino_simulator.daily.challenge.v1"
        private let legacyKeys = ["project.daily.challenge.v1", "projectx.daily.challenge.v1"]

        func read() -> DailyChallengeSnapshot? {
            if let data = UserDefaults.standard.data(forKey: storageKey),
               let decoded = try? JSONDecoder().decode(DailyChallengeSnapshot.self, from: data) {
                return decoded
            }

            for key in legacyKeys {
                if let data = UserDefaults.standard.data(forKey: key),
                   let decoded = try? JSONDecoder().decode(DailyChallengeSnapshot.self, from: data) {
                    UserDefaults.standard.set(data, forKey: storageKey)
                    return decoded
                }
            }

            return nil
        }

        func write(_ value: DailyChallengeSnapshot) {
            guard let data = try? JSONEncoder().encode(value) else { return }
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
