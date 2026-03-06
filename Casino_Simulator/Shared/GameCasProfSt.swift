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
            case .emerald: return "castle"
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

    @Published private(set) var state: SaveState

    @Published private(set) var inventoryEventAssetName: String = "hot_event"
    @Published private(set) var inventoryEventMode: CasinoMode = .hot

    private let persistence = PersistenceBox()
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

    var coins: Int { state.balance }
    var level: Int { state.rank }
    var xpInLevel: Int { state.xp }
    var xpToNextLevel: Int { Self.requiredXP(for: state.rank) }

    var totalWon: Int { state.wonTotal }
    var totalLost: Int { state.lostTotal }
    var totalSpins: Int { state.spinCount }
    var loginStreak: Int { state.streakDays }
    var totalAppLaunches: Int { state.launchCount }

    var favoriteCasino: CasinoMode {
        let sorted = state.modePlays.sorted { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key.rawValue < rhs.key.rawValue }
            return lhs.value > rhs.value
        }
        return sorted.first?.key ?? .hot
    }

    var totalAchievementsCount: Int { AchievementDefinitions.all.count }
    var totalQuestsCount: Int { QuestDefinitions.all.count }

    var completedAchievementsCount: Int {
        AchievementDefinitions.all.reduce(into: 0) { result, item in
            let value = state.achievementValues[item.id] ?? 0
            if value >= item.target { result += 1 }
        }
    }

    var completedQuestsCount: Int {
        QuestDefinitions.all.reduce(into: 0) { result, item in
            let value = state.questValues[item.id] ?? 0
            if value >= item.target { result += 1 }
        }
    }

    var claimedAchievementsCount: Int {
        state.claimedRewards.filter { $0.type == .achievement }.count
    }

    var claimedQuestsCount: Int {
        state.claimedRewards.filter { $0.type == .quest }.count
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

    private init() {
        let now = Date()
        if let saved = persistence.read() {
            state = saved
        } else {
            state = SaveState.initial(at: now)
            persistence.write(state)
        }

        setupInventoryEvents(now: now)

        registerAppLaunch(now: now)
        prepareProgressStorage()
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
            state.achievementValues[AchievementDefinitions.dailyStreak5.id] = state.streakDays
            hasChanges = true
        }

        if hasChanges {
            syncDerivedQuests()
            syncDerivedAchievements()
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

    func canAffordBet(_ bet: Int, minBet: Int) -> Bool {
        let normalized = max(minBet, bet)
        return normalized <= state.balance
    }

    func normalizedBet(_ bet: Int, minBet: Int) -> Int {
        let lowerBounded = max(minBet, bet)
        return min(lowerBounded, max(minBet, state.balance))
    }

    func spin(mode: CasinoMode, bet: Int, minBet: Int = 100) -> SpinResolution? {
        let finalBet = normalizedBet(bet, minBet: minBet)
        guard finalBet >= minBet, finalBet <= state.balance else { return nil }

        noteGameplayActivity(now: Date())

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

        noteCasinoPlayedForFavoriteQuest(mode: mode)
        advanceQuestProgressAfterWin(multiplier: roll.multiplier)

        let xp = Self.calculateXP(for: finalBet, multiplier: roll.multiplier)
        _ = applyXP(xp)

        syncDerivedQuests()
        syncDerivedAchievements()

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
            timestamp: Date()
        )
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
        saveChanges()
    }

    func resetAllProgress() {
        state = SaveState.initial(at: Date())
        didRegisterSessionLaunch = false
        registerAppLaunch()
        prepareProgressStorage()
        rotateInventoryEvent(now: Date(), force: true)
        saveChanges()
    }

    func spendPokerBetImmediately(_ amount: Int) -> Bool {
        let safeAmount = max(0, amount)
        guard safeAmount > 0 else { return false }
        guard state.balance >= safeAmount else { return false }

        noteGameplayActivity(now: Date())

        state.balance -= safeAmount
        saveChanges()
        return true
    }

    func applyPokerHandDelta(_ delta: Int) {
        noteGameplayActivity(now: Date())

        if delta == 0 {
            state.modePlays[.poker, default: 0] += 1
            noteCasinoPlayedForFavoriteQuest(mode: .poker)
            syncDerivedQuests()
            syncDerivedAchievements()
            saveChanges()
            return
        }

        if delta > 0 {
            state.balance += delta
            state.wonTotal += delta
        } else {
            let loss = abs(delta)
            state.balance = max(0, state.balance - loss)
            state.lostTotal += loss
        }

        state.modePlays[.poker, default: 0] += 1
        noteCasinoPlayedForFavoriteQuest(mode: .poker)

        syncDerivedQuests()
        syncDerivedAchievements()
        saveChanges()
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
        state.achievementValues[AchievementDefinitions.dailyStreak5.id] =
            max(state.achievementValues[AchievementDefinitions.dailyStreak5.id] ?? 0, state.streakDays)

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
                self.tickInventoryRotation(now: now)
            }
    }

    private func noteGameplayActivity(now: Date) {
        lastGameplayActivityAt = now
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

    private final class PersistenceBox {
        private let storageKey = "projectx.cas.prof.state.v3"

        func read() -> SaveState? {
            guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
            return try? JSONDecoder().decode(SaveState.self, from: data)
        }

        func write(_ value: SaveState) {
            guard let data = try? JSONEncoder().encode(value) else { return }
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
