// Path: Games/GamePoker.swift

import SwiftUI
import UIKit

struct GamePokerView: View {
    let game: GameCasProfSt.CasinoMode
    let onClose: () -> Void

    @EnvironmentObject private var profile: GameCasProfSt
    @EnvironmentObject private var avatarStore: ProfileAvatarStore

    @State private var selectedBet: Int = 300

    @State private var heroStack: Int = 5000
    @State private var leftBotStack: Int = 5000
    @State private var rightBotStack: Int = 5000

    @State private var heroCards: [PokerCard] = []
    @State private var leftBotCards: [PokerCard] = []
    @State private var rightBotCards: [PokerCard] = []
    @State private var communityCards: [PokerCard] = []

    @State private var deck: [PokerCard] = []

    @State private var pot: Int = 0
    @State private var currentRoundBet: Int = 0
    @State private var heroCommitted: Int = 0
    @State private var leftCommitted: Int = 0
    @State private var rightCommitted: Int = 0

    @State private var heroFolded = false
    @State private var leftFolded = false
    @State private var rightFolded = false

    @State private var heroActed = false
    @State private var leftActed = false
    @State private var rightActed = false

    @State private var phase: TablePhase = .waitingStart
    @State private var actionMessage: String = "Press DEAL to start a hand."
    @State private var resultBanner: String = ""
    @State private var showResultBanner = false

    @State private var isBusy = false
    @State private var showBetSheet = false

    @State private var showNoCoinsPulse = false
    @State private var pulseTask: Task<Void, Never>?
    @State private var resultHideTask: Task<Void, Never>?

    @State private var lastTapDate: Date = .distantPast
    @State private var heroHandStartStack: Int = 0

    @State private var betDraft: Int = 300

    private let minBet = 100
    private let maxBet = 10_000

    private enum Assets {
        static let background = "back_hot"
        static let avatarPlaceholder = "avatar_placeholder"
    }

    private enum Theme {
        static func color(_ hex: String) -> Color {
            let cleaned = hex
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "#", with: "")
            var int: UInt64 = 0
            Scanner(string: cleaned).scanHexInt64(&int)

            let r: UInt64
            let g: UInt64
            let b: UInt64

            switch cleaned.count {
            case 6:
                r = (int >> 16) & 0xFF
                g = (int >> 8) & 0xFF
                b = int & 0xFF
            default:
                r = 255
                g = 255
                b = 255
            }

            return Color(
                .sRGB,
                red: Double(r) / 255.0,
                green: Double(g) / 255.0,
                blue: Double(b) / 255.0,
                opacity: 1.0
            )
        }

        static let panelFill = color("07131E")
        static let panelFill2 = color("050B12")
        static let strokeA = color("4DE6FF")
        static let strokeB = color("B7F7FF")
        static let gold = color("FFE08A")
        static let warm = color("FFB25E")
        static let text = color("EAF6FF")
        static let dim = color("9CB2BF")
        static let green = color("60F5C9")
        static let red = color("FF6A6A")
        static let tableGlow = color("23B7FF")
        static let deepShadow = Color.black.opacity(0.38)
    }

    private enum Typography {
        static let candidates: [String] = [
            "MadimiOne-Regular",
            "MadimiOne_Regular",
            "MadimiOne Regular"
        ]

        static func font(size: CGFloat) -> Font {
            for name in candidates where UIFont(name: name, size: size) != nil {
                return .custom(name, size: size)
            }
            return .system(size: size, weight: .heavy, design: .rounded)
        }
    }

    private enum Layout {
        static func isCompact(_ w: CGFloat) -> Bool { w <= 375 }

        struct M {
            let side: CGFloat
            let tableCorner: CGFloat
            let tableStroke: CGFloat
            let tablePad: CGFloat
            let playerCardW: CGFloat
            let playerCardH: CGFloat
            let heroCardW: CGFloat
            let heroCardH: CGFloat
            let communityCardW: CGFloat
            let communityCardH: CGFloat
            let playerGap: CGFloat
            let communityGap: CGFloat
            let actionBtnH: CGFloat
            let actionBtnGap: CGFloat
            let bottomH: CGFloat
            let bottomPad: CGFloat
            let potCenterWidth: CGFloat
            let tableHeight: CGFloat
            let titleHeight: CGFloat
            let hudTopInset: CGFloat
            let globalDownShift: CGFloat
            let topContentInsetDelta: CGFloat
            let backButtonTopGap: CGFloat
            let backButtonWidth: CGFloat
            let backButtonHeight: CGFloat
            let backButtonCorner: CGFloat
            let backButtonStroke: CGFloat
            let backButtonTextSize: CGFloat

            let betSheetCorner: CGFloat
            let betSheetSide: CGFloat
            let betSheetMaxW: CGFloat
            let betChipH: CGFloat
            let betChipCorner: CGFloat
            let betGridGap: CGFloat
        }

        static let compact = M(
            side: 24,
            tableCorner: 22,
            tableStroke: 2.6,
            tablePad: 9,
            playerCardW: 26,
            playerCardH: 40,
            heroCardW: 40,
            heroCardH: 62,
            communityCardW: 32,
            communityCardH: 48,
            playerGap: 5,
            communityGap: 5,
            actionBtnH: 40,
            actionBtnGap: 8,
            bottomH: 50,
            bottomPad: 5,
            potCenterWidth: 72,
            tableHeight: 385,
            titleHeight: 20,
            hudTopInset: 34,
            globalDownShift: 10,
            topContentInsetDelta: 54,
            backButtonTopGap: 10,
            backButtonWidth: 132,
            backButtonHeight: 36,
            backButtonCorner: 18,
            backButtonStroke: 2.4,
            backButtonTextSize: 15,
            betSheetCorner: 26,
            betSheetSide: 14,
            betSheetMaxW: 520,
            betChipH: 46,
            betChipCorner: 18,
            betGridGap: 10
        )

        static let regular = M(
            side: 30,
            tableCorner: 24,
            tableStroke: 2.9,
            tablePad: 11,
            playerCardW: 30,
            playerCardH: 44,
            heroCardW: 46,
            heroCardH: 68,
            communityCardW: 36,
            communityCardH: 52,
            playerGap: 6,
            communityGap: 6,
            actionBtnH: 44,
            actionBtnGap: 9,
            bottomH: 54,
            bottomPad: 6,
            potCenterWidth: 78,
            tableHeight: 405,
            titleHeight: 22,
            hudTopInset: 58,
            globalDownShift: 14,
            topContentInsetDelta: 58,
            backButtonTopGap: 12,
            backButtonWidth: 144,
            backButtonHeight: 40,
            backButtonCorner: 20,
            backButtonStroke: 2.7,
            backButtonTextSize: 16,
            betSheetCorner: 30,
            betSheetSide: 18,
            betSheetMaxW: 560,
            betChipH: 50,
            betChipCorner: 20,
            betGridGap: 12
        )

        static func m(for w: CGFloat) -> M { isCompact(w) ? compact : regular }
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let backgroundHeight = max(h, UIScreen.main.bounds.height)
            let m = Layout.m(for: w)
            let blockWidth = max(0, w - m.side * 2)

            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom

            let titleToTableSpacing: CGFloat = Layout.isCompact(w) ? 8 : 10
            let tableToActionsSpacing: CGFloat = Layout.isCompact(w) ? 12 : 14
            let actionsToBottomSpacing: CGFloat = Layout.isCompact(w) ? 6 : 8
            let topContentInset: CGFloat = safeTop + m.hudTopInset + m.globalDownShift + m.topContentInsetDelta
            let bottomContentInset: CGFloat = Layout.isCompact(w) ? max(10, safeBottom - 2) : safeBottom + 6
            let backButtonToBottomSpacing: CGFloat = Layout.isCompact(w) ? 10 : 12

            ZStack {
                Color.black.ignoresSafeArea()

                Image(Assets.background)
                    .resizable()
                    .scaledToFill()
                    .frame(width: max(w, UIScreen.main.bounds.width), height: backgroundHeight)
                    .clipped()
                    .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        Theme.tableGlow.opacity(0.20),
                        Color.black.opacity(0.12),
                        Color.black.opacity(0.60)
                    ],
                    center: .top,
                    startRadius: 10,
                    endRadius: max(320, backgroundHeight * 0.80)
                )
                .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.10),
                        Color.black.opacity(0.22),
                        Color.black.opacity(0.68)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    TopHUDView(onOpenProfile: onClose)
                        .padding(.top, m.hudTopInset)
                        .frame(width: blockWidth)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer(minLength: 0)
                }
                .padding(.top, m.globalDownShift)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .zIndex(15)

                VStack(spacing: 0) {
                    Spacer(minLength: topContentInset)

                    VStack(spacing: 0) {
                        Text("POKER TABLE")
                            .font(Typography.font(size: m.titleHeight))
                            .foregroundColor(Theme.gold)
                            .shadow(color: Theme.deepShadow, radius: 10, x: 0, y: 6)

                        Spacer().frame(height: titleToTableSpacing)

                        tableArea(m: m, width: blockWidth)

                        Spacer().frame(height: tableToActionsSpacing)

                        actionControls(m: m, width: blockWidth)

                        Spacer().frame(height: actionsToBottomSpacing)

                        bottomBetPanel(m: m, width: blockWidth)

                        Spacer().frame(height: m.backButtonTopGap)

                        Button { onClose() } label: {
                            ZStack {
                                Capsule(style: .continuous)
                                    .fill(Theme.panelFill.opacity(0.94))

                                Capsule(style: .continuous)
                                    .stroke(
                                        LinearGradient(colors: [Theme.strokeA, Theme.strokeB], startPoint: .leading, endPoint: .trailing),
                                        lineWidth: m.backButtonStroke
                                    )

                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: max(12, m.backButtonTextSize - 2), weight: .black))
                                        .foregroundColor(Theme.text.opacity(0.95))

                                    Text("Back")
                                        .font(Typography.font(size: m.backButtonTextSize))
                                        .foregroundColor(Theme.text)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)

                                    Spacer(minLength: 0)
                                }
                                .padding(.horizontal, 14)
                            }
                            .frame(width: m.backButtonWidth, height: m.backButtonHeight)
                            .shadow(color: Theme.deepShadow, radius: 10, x: 0, y: 6)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: blockWidth)

                    Spacer(minLength: bottomContentInset + backButtonToBottomSpacing)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(10)

                if showResultBanner {
                    resultBannerView
                        .frame(width: blockWidth)
                        .padding(.top, safeTop + 44)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(20)
                }

                if showBetSheet {
                    betSheetOverlay(m: m, safeBottom: safeBottom)
                        .zIndex(30)
                        .transition(.opacity)
                }
            }
            .frame(width: max(w, UIScreen.main.bounds.width), height: backgroundHeight)
            .background(Color.black.ignoresSafeArea())
            .ignoresSafeArea()
            .onAppear {
                selectedBet = clampBet(selectedBet)
                heroStack = max(1, heroStack)
                selectedBet = min(selectedBet, maxSelectableBet)
                betDraft = selectedBet
                if heroStack <= 0 { heroStack = max(5000, profile.coins) }
                resetTable(keepStacks: true)
            }
            .onChange(of: heroStack) { _ in
                let cap = maxSelectableBet
                if selectedBet > cap { selectedBet = cap }
                if betDraft > cap { betDraft = cap }
            }
            .onDisappear {
                pulseTask?.cancel()
                resultHideTask?.cancel()
            }
        }
    }

    private func betSheetOverlay(m: Layout.M, safeBottom: CGFloat) -> some View {
        BetSheetOverlay(
            isPresented: $showBetSheet,
            draft: $betDraft,
            selected: $selectedBet,
            maxAllowed: maxSelectableBet,
            bets: availableBets,
            formatCoins: formatCoins,
            theme: BetSheetOverlay.Theme(
                panelFill: Theme.panelFill,
                panelFill2: Theme.panelFill2,
                strokeA: Theme.strokeA,
                strokeB: Theme.strokeB,
                gold: Theme.gold,
                warm: Theme.warm,
                text: Theme.text,
                dim: Theme.dim,
                glow: Theme.tableGlow
            ),
            typography: BetSheetOverlay.Typography(font: Typography.font),
            metrics: BetSheetOverlay.Metrics(
                corner: m.betSheetCorner,
                side: m.betSheetSide,
                maxW: m.betSheetMaxW,
                chipH: m.betChipH,
                chipCorner: m.betChipCorner,
                gridGap: m.betGridGap,
                bottomPad: max(14, safeBottom + 10)
            )
        ) { newValue in
            selectedBet = clampBet(newValue)
            selectedBet = min(selectedBet, maxSelectableBet)
        }
    }

    private func tableArea(m: Layout.M, width: CGFloat) -> some View {
        VStack(spacing: 8) {
            topBotsRow(m: m, width: width - m.tablePad * 2)
            communityRow(m: m)
            heroRow(m: m, width: width - m.tablePad * 2)
            tableInfoStrip
        }
        .padding(m.tablePad)
        .frame(width: width, height: m.tableHeight, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: m.tableCorner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.panelFill.opacity(0.96),
                            Theme.panelFill2.opacity(0.98),
                            Theme.panelFill.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: m.tableCorner, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Theme.strokeA.opacity(0.95), Theme.strokeB.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: m.tableStroke
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: max(6, m.tableCorner - 3), style: .continuous)
                .stroke(Theme.tableGlow.opacity(0.16), lineWidth: 1)
                .padding(5)
        )
        .shadow(color: Theme.deepShadow, radius: 18, x: 0, y: 12)
    }

    private func topBotsRow(m: Layout.M, width: CGFloat) -> some View {
        let rowSpacing = m.playerGap
        let seatMinW: CGFloat = max(72, (m.playerCardW * 2) + m.playerGap)
        let potMinW: CGFloat = 50
        let maxPotBySeats = max(potMinW, width - (seatMinW * 2) - (rowSpacing * 2))
        let potW = min(m.potCenterWidth, maxPotBySeats)
        let computedSeatW = max(0, (width - potW - (rowSpacing * 2)) / 2)
        let seatW = max(seatMinW, computedSeatW)

        return HStack(spacing: rowSpacing) {
            botSeatView(
                title: "BOT L",
                stack: leftBotStack,
                cards: leftBotCards,
                folded: leftFolded,
                revealCards: showdownForcedReveal,
                cardW: m.playerCardW,
                cardH: m.playerCardH,
                gap: m.playerGap,
                alignLeading: true
            )
            .frame(width: seatW, alignment: .leading)

            potCenterView(width: potW)
                .frame(width: potW)

            botSeatView(
                title: "BOT R",
                stack: rightBotStack,
                cards: rightBotCards,
                folded: rightFolded,
                revealCards: showdownForcedReveal,
                cardW: m.playerCardW,
                cardH: m.playerCardH,
                gap: m.playerGap,
                alignLeading: false
            )
            .frame(width: seatW, alignment: .trailing)
        }
        .frame(width: width, alignment: .center)
    }

    private func communityRow(m: Layout.M) -> some View {
        HStack(spacing: m.communityGap) {
            ForEach(0..<5, id: \.self) { index in
                if index < communityCards.count {
                    pokerCardView(
                        communityCards[index],
                        isFaceUp: true,
                        width: m.communityCardW,
                        height: m.communityCardH
                    )
                } else {
                    emptyCardPlaceholder(width: m.communityCardW, height: m.communityCardH)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 0)
    }

    private func heroRow(m: Layout.M, width: CGFloat) -> some View {
        VStack(spacing: 5) {
            HStack(alignment: .center, spacing: 8) {
                HStack(alignment: .center, spacing: 6) {
                    avatarCircle(size: 34)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("YOU")
                            .font(Typography.font(size: 13))
                            .foregroundColor(Theme.text)

                        Text("Stack \(formatCoins(heroStack))")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.dim)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: m.playerGap) {
                    ForEach(0..<2, id: \.self) { idx in
                        if idx < heroCards.count {
                            pokerCardView(heroCards[idx], isFaceUp: true, width: m.heroCardW, height: m.heroCardH)
                        } else {
                            emptyCardPlaceholder(width: m.heroCardW, height: m.heroCardH)
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                seatStatusChip(
                    heroFolded ? "FOLDED" : heroHandPreviewText,
                    color: heroFolded ? Theme.red : Theme.green.opacity(0.92)
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                statPill("Pot", value: formatCoins(pot))
                statPill("To Call", value: formatCoins(max(0, currentRoundBet - heroCommitted)))
                statPill("Street", value: phase.displayName)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: width, alignment: .center)
    }

    private var tableInfoStrip: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Theme.strokeA.opacity(0.18))
                    .frame(width: 18, height: 18)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(Theme.warm)
            }

            Text(actionMessage)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.text.opacity(0.92))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 10)
        .frame(height: 28)
        .background(
            Capsule(style: .continuous)
                .fill(Color.black.opacity(0.18))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Theme.strokeB.opacity(0.12), lineWidth: 1)
        )
    }

    private func actionControls(m: Layout.M, width: CGFloat) -> some View {
        HStack(spacing: m.actionBtnGap) {
            actionButton(title: "FOLD", enabled: canHeroAct, primary: false, action: heroFold)
            actionButton(title: callButtonTitle, enabled: canHeroAct && heroCanCallOrCheck, primary: true, action: heroCallOrCheck)
            actionButton(title: "RAISE", enabled: canHeroAct && heroCanRaise, primary: false, action: heroRaise)
        }
        .frame(width: width, height: m.actionBtnH, alignment: .center)
    }

    private func bottomBetPanel(m: Layout.M, width: CGFloat) -> some View {
        let innerH = m.bottomH - m.bottomPad * 2

        return ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.panelFill.opacity(0.94))

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Theme.strokeA.opacity(0.95), Theme.strokeB.opacity(0.80)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.4
                )

            HStack(spacing: 7) {
                Button {
                    guard !isBusy else { return }
                    let cap = maxSelectableBet
                    selectedBet = min(selectedBet, cap)
                    betDraft = min(selectedBet, cap)
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.92)) {
                        showBetSheet = true
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Capsule(style: .continuous)
                        .fill(Theme.panelFill2)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Theme.strokeA.opacity(0.65), lineWidth: 1.5)
                        )
                        .overlay(
                            HStack(spacing: 6) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(Theme.text.opacity(0.95))
                                Text("Bet")
                                    .font(Typography.font(size: 14))
                                    .foregroundColor(Theme.text)
                            }
                        )
                }
                .buttonStyle(.plain)
                .frame(width: 92, height: innerH)

                ZStack {
                    Capsule(style: .continuous)
                        .fill(Theme.panelFill2)

                    Capsule(style: .continuous)
                        .stroke(Theme.strokeB.opacity(0.35), lineWidth: 1.4)

                    Text(formatCoins(selectedBet))
                        .font(Typography.font(size: 15))
                        .foregroundColor(Theme.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
                .frame(width: 110, height: innerH)

                Button {
                    dealNewHand()
                } label: {
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Theme.strokeA, Theme.strokeB],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Theme.gold.opacity(0.85), lineWidth: 1.4)
                        )
                        .overlay(
                            HStack(spacing: 7) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 11, weight: .black))
                                Text("DEAL")
                                    .font(Typography.font(size: 14))
                            }
                            .foregroundColor(.black.opacity(0.82))
                        )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, minHeight: innerH, maxHeight: innerH)
                .disabled(!canStartNewHand)
                .opacity(canStartNewHand ? 1.0 : 0.6)
            }
            .padding(.horizontal, m.bottomPad)
            .padding(.vertical, m.bottomPad)
        }
        .frame(width: width, height: m.bottomH, alignment: .center)
        .scaleEffect(showNoCoinsPulse ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.14), value: showNoCoinsPulse)
    }

    private var resultBannerView: some View {
        HStack(spacing: 9) {
            ZStack {
                Circle()
                    .fill(Theme.gold.opacity(0.18))
                    .frame(width: 22, height: 22)
                Image(systemName: "crown.fill")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(Theme.gold)
            }

            Text(resultBanner)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Theme.text)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule(style: .continuous)
                .fill(Theme.panelFill.opacity(0.94))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Theme.strokeA.opacity(0.95), Theme.strokeB.opacity(0.80)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Theme.deepShadow, radius: 12, x: 0, y: 8)
    }

    private func botSeatView(
        title: String,
        stack: Int,
        cards: [PokerCard],
        folded: Bool,
        revealCards: Bool,
        cardW: CGFloat,
        cardH: CGFloat,
        gap: CGFloat,
        alignLeading: Bool
    ) -> some View {
        VStack(alignment: alignLeading ? .leading : .trailing, spacing: 6) {
            HStack(spacing: 4) {
                if alignLeading {
                    Text(title)
                        .font(Typography.font(size: 12))
                        .foregroundColor(Theme.text)
                    Text("• \(formatCoins(stack))")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.dim)
                } else {
                    Text("\(formatCoins(stack)) •")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.dim)
                    Text(title)
                        .font(Typography.font(size: 12))
                        .foregroundColor(Theme.text)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            HStack(spacing: gap) {
                ForEach(0..<2, id: \.self) { idx in
                    if idx < cards.count {
                        pokerCardView(cards[idx], isFaceUp: revealCards && !folded, width: cardW, height: cardH)
                    } else {
                        emptyCardPlaceholder(width: cardW, height: cardH)
                    }
                }
            }

            seatStatusChip(
                folded ? "FOLDED" : (revealCards ? botHandText(title: title) : "IN HAND"),
                color: folded ? Theme.red : Theme.green.opacity(0.92)
            )
        }
    }

    private func seatStatusChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .black, design: .rounded))
            .foregroundColor(.black.opacity(0.88))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule(style: .continuous).fill(color))
            .overlay(Capsule(style: .continuous).stroke(Color.black.opacity(0.18), lineWidth: 1))
    }

    private func statPill(_ title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(Theme.dim.opacity(0.95))

            Text(value)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(Theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Capsule(style: .continuous).fill(Color.black.opacity(0.18)))
        .overlay(Capsule(style: .continuous).stroke(Theme.strokeB.opacity(0.08), lineWidth: 1))
    }

    private func potCenterView(width: CGFloat) -> some View {
        VStack(spacing: 4) {
            Text("POT")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(Theme.dim)

            Text(formatCoins(pot))
                .font(Typography.font(size: 13))
                .foregroundColor(Theme.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(phase.displayName)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundColor(Theme.text.opacity(0.92))
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Capsule(style: .continuous).fill(Color.black.opacity(0.22)))
                .overlay(Capsule(style: .continuous).stroke(Theme.strokeA.opacity(0.18), lineWidth: 1))
        }
        .frame(width: width)
    }

    private func avatarCircle(size: CGFloat) -> some View {
        Group {
            if let image = avatarStore.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(Assets.avatarPlaceholder)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(
                LinearGradient(
                    colors: [Theme.strokeA.opacity(0.85), Theme.strokeB.opacity(0.70)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
        )
        .shadow(color: Theme.tableGlow.opacity(0.16), radius: 10, x: 0, y: 6)
    }

    private func actionButton(title: String, enabled: Bool, primary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Capsule(style: .continuous)
                    .fill(
                        primary
                        ? LinearGradient(colors: [Theme.strokeA, Theme.strokeB], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Theme.panelFill, Theme.panelFill2], startPoint: .top, endPoint: .bottom)
                    )

                Capsule(style: .continuous)
                    .stroke(
                        primary ? Theme.gold.opacity(0.70) : Theme.strokeA.opacity(0.35),
                        lineWidth: primary ? 1.6 : 1.2
                    )

                Text(title)
                    .font(Typography.font(size: 14))
                    .foregroundColor(primary ? .black.opacity(0.85) : Theme.text.opacity(enabled ? 0.95 : 0.4))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .opacity(enabled ? 1 : 0.55)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func emptyCardPlaceholder(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Theme.strokeB.opacity(0.10), lineWidth: 1)
            )
            .frame(width: width, height: height)
    }

    private func pokerCardView(_ card: PokerCard, isFaceUp: Bool, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isFaceUp ? Color.white : Theme.panelFill2)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isFaceUp ? Theme.strokeA.opacity(0.32) : Theme.strokeB.opacity(0.16), lineWidth: 1.2)

            if isFaceUp {
                let suitColor = card.suit.isRed ? Theme.red : Color.black
                let rank = card.rank.label
                let suit = card.suit.symbol

                ZStack {
                    Text(suit)
                        .font(.system(size: max(14, height * 0.24), weight: .bold))
                        .foregroundColor(suitColor.opacity(0.92))

                    VStack {
                        HStack(alignment: .top) {
                            VStack(spacing: -1) {
                                Text(rank)
                                    .font(.system(size: max(9, width * 0.20), weight: .bold, design: .rounded))
                                Text(suit)
                                    .font(.system(size: max(9, width * 0.19), weight: .bold))
                            }
                            .foregroundColor(suitColor)

                            Spacer(minLength: 0)
                        }

                        Spacer(minLength: 0)

                        HStack {
                            Spacer(minLength: 0)

                            VStack(spacing: -1) {
                                Text(suit)
                                    .font(.system(size: max(9, width * 0.19), weight: .bold))
                                Text(rank)
                                    .font(.system(size: max(9, width * 0.20), weight: .bold, design: .rounded))
                            }
                            .rotationEffect(.degrees(180))
                            .foregroundColor(suitColor)
                        }
                    }
                    .padding(5)
                }
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Theme.panelFill.opacity(0.86), Theme.panelFill2.opacity(0.98)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(2)

                Image(systemName: "sparkle")
                    .font(.system(size: max(11, height * 0.20), weight: .black))
                    .foregroundColor(Theme.strokeA.opacity(0.72))
            }
        }
        .frame(width: width, height: height)
    }

    // MARK: - Bets (bug fix)

    private var maxSelectableBet: Int {
        max(minBet, min(maxBet, max(0, heroStack)))
    }

    private var availableBets: [Int] {
        let base = [100, 200, 300, 500, 1_000, 2_500, 5_000, 10_000]
        let cap = maxSelectableBet
        let arr = base.filter { $0 <= cap }
        return arr.isEmpty ? [minBet] : arr
    }

    enum TablePhase: Equatable {
        case waitingStart
        case preflop
        case flop
        case turn
        case river
        case showdown
        case handEnded

        var displayName: String {
            switch self {
            case .waitingStart: return "WAIT"
            case .preflop: return "PREFLOP"
            case .flop: return "FLOP"
            case .turn: return "TURN"
            case .river: return "RIVER"
            case .showdown: return "SHOWDOWN"
            case .handEnded: return "ENDED"
            }
        }
    }

    private var canStartNewHand: Bool { !isBusy && (phase == .waitingStart || phase == .handEnded) }

    private var canHeroAct: Bool {
        !isBusy &&
        !heroFolded &&
        heroStack > 0 &&
        (phase == .preflop || phase == .flop || phase == .turn || phase == .river) &&
        !heroActed
    }

    private var heroCanCallOrCheck: Bool {
        let toCall = max(0, currentRoundBet - heroCommitted)
        return heroStack >= toCall
    }

    private var heroCanRaise: Bool {
        let toCall = max(0, currentRoundBet - heroCommitted)
        return heroStack > (toCall + selectedBet)
    }

    private var callButtonTitle: String {
        let toCall = max(0, currentRoundBet - heroCommitted)
        if toCall == 0 { return "CHECK" }
        return "CALL \(formatCoins(toCall))"
    }

    private var showdownForcedReveal: Bool { phase == .showdown || phase == .handEnded }

    private var heroHandPreviewText: String {
        guard !heroFolded else { return "FOLDED" }
        guard !heroCards.isEmpty else { return "READY" }
        let all = heroCards + communityCards
        guard all.count >= 5 else { return "IN HAND" }
        return PokerEvaluator.bestHand(from: all).category.displayName.uppercased()
    }

    private func botHandText(title: String) -> String {
        let cards: [PokerCard] = title == "BOT L" ? leftBotCards : rightBotCards
        let folded: Bool = title == "BOT L" ? leftFolded : rightFolded
        guard !folded else { return "FOLDED" }
        let all = cards + communityCards
        guard all.count >= 5 else { return "IN HAND" }
        return PokerEvaluator.bestHand(from: all).category.displayName.uppercased()
    }

    private func dealNewHand() {
        guard canStartNewHand else { return }

        selectedBet = min(selectedBet, maxSelectableBet)

        guard heroStack >= selectedBet else {
            actionMessage = "Not enough chips in table stack for this bet."
            pulseCoins()
            return
        }

        let now = Date()
        if now.timeIntervalSince(lastTapDate) < 0.08 { return }
        lastTapDate = now

        resultHideTask?.cancel()
        hideResultBanner()

        isBusy = true
        resetTable(keepStacks: true)

        deck = PokerDeck.shuffled()

        heroCards = draw(2)
        leftBotCards = draw(2)
        rightBotCards = draw(2)

        phase = .preflop
        actionMessage = "New hand started. Posting ante."

        let ante = clampAnte(selectedBet)

        guard profile.spendPokerBetImmediately(ante) else {
            actionMessage = "Not enough coins."
            resetTable(keepStacks: true)
            isBusy = false
            pulseCoins()
            return
        }

        postForcedBet(for: .hero, amount: ante)
        postForcedBet(for: .leftBot, amount: ante)
        postForcedBet(for: .rightBot, amount: ante)

        currentRoundBet = ante
        heroCommitted = ante
        leftCommitted = ante
        rightCommitted = ante

        heroActed = false
        leftActed = false
        rightActed = false

        heroHandStartStack = heroStack

        isBusy = false
        actionMessage = "Your action: CHECK / CALL / RAISE / FOLD"
    }

    private func heroFold() {
        guard canHeroAct else { return }
        heroFolded = true
        heroActed = true
        actionMessage = "You folded."
        Task { await continueAfterHeroAction() }
    }

    private func heroCallOrCheck() {
        guard canHeroAct else { return }

        let toCall = max(0, currentRoundBet - heroCommitted)
        let paid = commitChips(from: .hero, amount: toCall)
        heroCommitted += paid
        heroActed = true

        actionMessage = toCall == 0 ? "You checked." : "You called \(formatCoins(paid))."
        Task { await continueAfterHeroAction() }
    }

    private func heroRaise() {
        guard canHeroAct else { return }

        let toCall = max(0, currentRoundBet - heroCommitted)
        let raiseAmount = min(selectedBet, max(0, heroStack - toCall))
        let total = toCall + raiseAmount
        guard total > 0 else { return }

        let paid = commitChips(from: .hero, amount: total)
        heroCommitted += paid
        currentRoundBet = max(currentRoundBet, heroCommitted)

        heroActed = true
        leftActed = false
        rightActed = false

        actionMessage = "You raised by \(formatCoins(max(0, paid - toCall)))."
        Task { await continueAfterHeroAction() }
    }

    @MainActor
    private func continueAfterHeroAction() async {
        guard !isBusy else { return }
        isBusy = true

        try? await Task.sleep(nanoseconds: 280_000_000)

        if let winner = singleRemainingWinner() {
            awardPotToSingleWinner(winner)
            isBusy = false
            return
        }

        if !leftFolded {
            botAct(.leftBot)
            try? await Task.sleep(nanoseconds: 250_000_000)
            if let winner = singleRemainingWinner() {
                awardPotToSingleWinner(winner)
                isBusy = false
                return
            }
        } else {
            leftActed = true
        }

        if !rightFolded {
            botAct(.rightBot)
            try? await Task.sleep(nanoseconds: 250_000_000)
            if let winner = singleRemainingWinner() {
                awardPotToSingleWinner(winner)
                isBusy = false
                return
            }
        } else {
            rightActed = true
        }

        if bettingRoundComplete {
            advanceStreetOrShowdown()
        } else {
            if !heroFolded {
                heroActed = false
                actionMessage = "Your action: \(callButtonTitle) / RAISE / FOLD"
                isBusy = false
                return
            } else {
                actionMessage = "Waiting bots..."
            }
        }

        if heroFolded {
            isBusy = false
            await autoplayBotsAfterHeroFold()
            return
        }

        isBusy = false
    }

    @MainActor
    private func autoplayBotsAfterHeroFold() async {
        guard heroFolded else { return }
        guard !isBusy else { return }

        isBusy = true

        while heroFolded && (phase == .preflop || phase == .flop || phase == .turn || phase == .river) {
            if let winner = singleRemainingWinner() {
                awardPotToSingleWinner(winner)
                break
            }

            if !leftFolded && !leftActed {
                botAct(.leftBot)
                try? await Task.sleep(nanoseconds: 220_000_000)
                if let winner = singleRemainingWinner() {
                    awardPotToSingleWinner(winner)
                    break
                }
            } else if leftFolded {
                leftActed = true
            }

            if !rightFolded && !rightActed {
                botAct(.rightBot)
                try? await Task.sleep(nanoseconds: 220_000_000)
                if let winner = singleRemainingWinner() {
                    awardPotToSingleWinner(winner)
                    break
                }
            } else if rightFolded {
                rightActed = true
            }

            if phase == .handEnded || phase == .showdown { break }

            if bettingRoundComplete {
                advanceStreetOrShowdown()
                try? await Task.sleep(nanoseconds: 260_000_000)
            } else {
                if !leftFolded && !leftActed { continue }
                if !rightFolded && !rightActed { continue }
                if !bettingRoundComplete {
                    leftActed = leftFolded
                    rightActed = rightFolded
                }
            }
        }

        isBusy = false
    }

    private var bettingRoundComplete: Bool {
        let activeSeats = activeSeatStates
        guard !activeSeats.isEmpty else { return true }
        let allActed = activeSeats.allSatisfy { $0.acted }
        let allMatched = activeSeats.allSatisfy { $0.committed == currentRoundBet || $0.stack == 0 }
        return allActed && allMatched
    }

    private func advanceStreetOrShowdown() {
        if let winner = singleRemainingWinner() {
            awardPotToSingleWinner(winner)
            return
        }

        switch phase {
        case .preflop:
            communityCards.append(contentsOf: draw(3))
            phase = .flop
            startNewBettingRound(streetMessage: heroFolded ? "Bots continue on flop..." : "Flop dealt. Your action.")
        case .flop:
            communityCards.append(contentsOf: draw(1))
            phase = .turn
            startNewBettingRound(streetMessage: heroFolded ? "Bots continue on turn..." : "Turn dealt. Your action.")
        case .turn:
            communityCards.append(contentsOf: draw(1))
            phase = .river
            startNewBettingRound(streetMessage: heroFolded ? "Bots continue on river..." : "River dealt. Your action.")
        case .river:
            resolveShowdown()
        default:
            break
        }
    }

    private func startNewBettingRound(streetMessage: String) {
        currentRoundBet = 0
        heroCommitted = 0
        leftCommitted = 0
        rightCommitted = 0

        heroActed = heroFolded
        leftActed = leftFolded
        rightActed = rightFolded

        actionMessage = streetMessage
    }

    private func resolveShowdown() {
        phase = .showdown

        var contenders: [(Seat, PokerHandValue)] = []

        if !heroFolded, heroCards.count == 2 {
            contenders.append((.hero, PokerEvaluator.bestHand(from: heroCards + communityCards)))
        }
        if !leftFolded, leftBotCards.count == 2 {
            contenders.append((.leftBot, PokerEvaluator.bestHand(from: leftBotCards + communityCards)))
        }
        if !rightFolded, rightBotCards.count == 2 {
            contenders.append((.rightBot, PokerEvaluator.bestHand(from: rightBotCards + communityCards)))
        }

        guard let bestPair = contenders.max(by: { $0.1 < $1.1 }) else {
            phase = .handEnded
            actionMessage = "Hand ended."
            finalizeHeroHandDelta()
            return
        }

        let winners = contenders.filter { $0.1 == bestPair.1 }.map(\.0)
        let share = winners.isEmpty ? 0 : (pot / winners.count)
        let remainder = winners.isEmpty ? 0 : (pot % winners.count)

        for (idx, seat) in winners.enumerated() {
            let extra = idx == 0 ? remainder : 0
            addChips(to: seat, amount: share + extra)
        }

        let bannerNames = winners.map(\.displayName).joined(separator: " / ")
        let handName = bestPair.1.category.displayName
        let heroWon = winners.contains(.hero)

        if heroWon {
            showResult("You win • \(handName) • \(heroDeltaText())")
            actionMessage = "Showdown: \(handName). \(heroDeltaText())."
        } else {
            showResult("\(bannerNames) win • \(handName)")
            actionMessage = "Showdown: \(bannerNames) won with \(handName)."
        }

        pot = 0
        phase = .handEnded
        finalizeHeroHandDelta()
    }

    private func awardPotToSingleWinner(_ seat: Seat) {
        let amount = pot
        addChips(to: seat, amount: amount)
        pot = 0
        phase = .handEnded

        if seat == .hero {
            showResult("You win • Others folded • \(heroDeltaText(afterAward: true))")
            actionMessage = "Everyone folded. You win the pot."
        } else {
            showResult("\(seat.displayName) wins • Others folded")
            actionMessage = "\(seat.displayName) wins the pot (others folded)."
        }

        finalizeHeroHandDelta()
    }

    private func botAct(_ seat: Seat) {
        guard phase == .preflop || phase == .flop || phase == .turn || phase == .river else { return }

        if seat == .leftBot, leftFolded {
            leftActed = true
            return
        }
        if seat == .rightBot, rightFolded {
            rightActed = true
            return
        }

        let toCall = max(0, currentRoundBet - committed(for: seat))
        let stack = stack(for: seat)
        let cards = holeCards(for: seat)
        let allKnown = cards + communityCards

        let strength = PokerBotBrain.estimateStrength(hole: cards, allCards: allKnown, phase: phase)
        let canRaise = stack > (toCall + selectedBet)

        let shouldFold: Bool
        let shouldRaise: Bool

        if toCall == 0 {
            shouldFold = false
            shouldRaise = canRaise && strength > 0.74
        } else if toCall <= selectedBet {
            shouldFold = strength < 0.26 && Double.random(in: 0...1) < 0.55
            shouldRaise = !shouldFold && canRaise && strength > 0.83 && Double.random(in: 0...1) < 0.55
        } else {
            shouldFold = strength < 0.40 && Double.random(in: 0...1) < 0.75
            shouldRaise = !shouldFold && canRaise && strength > 0.90 && Double.random(in: 0...1) < 0.35
        }

        if shouldFold {
            setFolded(seat, true)
            setActed(seat, true)
            actionMessage = "\(seat.displayName) folds."
            return
        }

        if shouldRaise {
            let total = toCall + min(selectedBet, max(0, stack - toCall))
            let paid = commitChips(from: seat, amount: total)
            setCommitted(seat, committed(for: seat) + paid)
            currentRoundBet = max(currentRoundBet, committed(for: seat))
            setActed(seat, true)

            if seat == .leftBot {
                rightActed = false
                if !heroFolded { heroActed = false }
            } else if seat == .rightBot {
                if !heroFolded { heroActed = false }
            }

            actionMessage = "\(seat.displayName) raises."
            return
        }

        let paid = commitChips(from: seat, amount: toCall)
        setCommitted(seat, committed(for: seat) + paid)
        setActed(seat, true)
        actionMessage = toCall == 0 ? "\(seat.displayName) checks." : "\(seat.displayName) calls."
    }

    private func resetTable(keepStacks: Bool) {
        heroCards = []
        leftBotCards = []
        rightBotCards = []
        communityCards = []
        deck = []

        pot = 0
        currentRoundBet = 0
        heroCommitted = 0
        leftCommitted = 0
        rightCommitted = 0

        heroFolded = false
        leftFolded = false
        rightFolded = false

        heroActed = false
        leftActed = false
        rightActed = false

        phase = .waitingStart
        actionMessage = "Press DEAL to start a hand."

        if !keepStacks {
            heroStack = max(5000, profile.coins)
            leftBotStack = 5000
            rightBotStack = 5000
        }
    }

    private func clampBet(_ value: Int) -> Int { max(minBet, min(maxBet, value)) }
    private func clampAnte(_ value: Int) -> Int { max(minBet, min(value, maxBet)) }

    private func draw(_ count: Int) -> [PokerCard] {
        var arr: [PokerCard] = []
        for _ in 0..<count {
            if deck.isEmpty { deck = PokerDeck.shuffled() }
            if let card = deck.first {
                arr.append(card)
                deck.removeFirst()
            }
        }
        return arr
    }

    private func postForcedBet(for seat: Seat, amount: Int) {
        _ = commitChips(from: seat, amount: amount)
    }

    @discardableResult
    private func commitChips(from seat: Seat, amount: Int) -> Int {
        let pay = max(0, min(amount, stack(for: seat)))
        guard pay > 0 else { return 0 }
        subtractChips(from: seat, amount: pay)
        pot += pay
        return pay
    }

    private func addChips(to seat: Seat, amount: Int) {
        guard amount > 0 else { return }
        switch seat {
        case .hero: heroStack += amount
        case .leftBot: leftBotStack += amount
        case .rightBot: rightBotStack += amount
        }
    }

    private func subtractChips(from seat: Seat, amount: Int) {
        guard amount > 0 else { return }
        switch seat {
        case .hero: heroStack = max(0, heroStack - amount)
        case .leftBot: leftBotStack = max(0, leftBotStack - amount)
        case .rightBot: rightBotStack = max(0, rightBotStack - amount)
        }
    }

    private func stack(for seat: Seat) -> Int {
        switch seat {
        case .hero: return heroStack
        case .leftBot: return leftBotStack
        case .rightBot: return rightBotStack
        }
    }

    private func committed(for seat: Seat) -> Int {
        switch seat {
        case .hero: return heroCommitted
        case .leftBot: return leftCommitted
        case .rightBot: return rightCommitted
        }
    }

    private func setCommitted(_ seat: Seat, _ value: Int) {
        switch seat {
        case .hero: heroCommitted = value
        case .leftBot: leftCommitted = value
        case .rightBot: rightCommitted = value
        }
    }

    private func setActed(_ seat: Seat, _ value: Bool) {
        switch seat {
        case .hero: heroActed = value
        case .leftBot: leftActed = value
        case .rightBot: rightActed = value
        }
    }

    private func setFolded(_ seat: Seat, _ value: Bool) {
        switch seat {
        case .hero: heroFolded = value
        case .leftBot: leftFolded = value
        case .rightBot: rightFolded = value
        }
    }

    private func holeCards(for seat: Seat) -> [PokerCard] {
        switch seat {
        case .hero: return heroCards
        case .leftBot: return leftBotCards
        case .rightBot: return rightBotCards
        }
    }

    private var activeSeatStates: [(seat: Seat, committed: Int, stack: Int, acted: Bool)] {
        var result: [(Seat, Int, Int, Bool)] = []
        if !heroFolded { result.append((.hero, heroCommitted, heroStack, heroActed)) }
        if !leftFolded { result.append((.leftBot, leftCommitted, leftBotStack, leftActed)) }
        if !rightFolded { result.append((.rightBot, rightCommitted, rightBotStack, rightActed)) }
        return result
    }

    private func singleRemainingWinner() -> Seat? {
        let active: [Seat] = [
            heroFolded ? nil : .hero,
            leftFolded ? nil : .leftBot,
            rightFolded ? nil : .rightBot
        ].compactMap { $0 }
        return active.count == 1 ? active[0] : nil
    }

    private func finalizeHeroHandDelta() {
        let delta = heroStack - heroHandStartStack
        guard heroHandStartStack > 0 else { return }
        profile.applyPokerHandDelta(delta)
        heroHandStartStack = heroStack
    }

    private func heroDeltaText(afterAward: Bool = false) -> String {
        let delta = heroStack - heroHandStartStack
        if delta > 0 { return "+\(formatCoins(delta))" }
        if delta < 0 { return "-\(formatCoins(abs(delta)))" }
        return afterAward ? "+0" : "EVEN"
    }

    private func showResult(_ text: String) {
        resultHideTask?.cancel()
        resultBanner = text

        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            showResultBanner = true
        }

        resultHideTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.18)) {
                showResultBanner = false
            }
        }
    }

    private func hideResultBanner() {
        resultHideTask?.cancel()
        withAnimation(.easeOut(duration: 0.16)) {
            showResultBanner = false
        }
    }

    private func pulseCoins() {
        pulseTask?.cancel()
        pulseTask = Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.10)) { showNoCoinsPulse = true }
            try? await Task.sleep(nanoseconds: 160_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.10)) { showNoCoinsPulse = false }
        }
    }

    private func formatCoins(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private enum Seat: String, CaseIterable {
        case hero
        case leftBot
        case rightBot

        var displayName: String {
            switch self {
            case .hero: return "YOU"
            case .leftBot: return "BOT L"
            case .rightBot: return "BOT R"
            }
        }
    }
}

private struct BetSheetOverlay: View {
    struct Theme {
        let panelFill: Color
        let panelFill2: Color
        let strokeA: Color
        let strokeB: Color
        let gold: Color
        let warm: Color
        let text: Color
        let dim: Color
        let glow: Color
    }

    struct Typography {
        let font: (CGFloat) -> Font
    }

    struct Metrics {
        let corner: CGFloat
        let side: CGFloat
        let maxW: CGFloat
        let chipH: CGFloat
        let chipCorner: CGFloat
        let gridGap: CGFloat
        let bottomPad: CGFloat
    }

    @Binding var isPresented: Bool
    @Binding var draft: Int
    @Binding var selected: Int

    let maxAllowed: Int
    let bets: [Int]
    let formatCoins: (Int) -> String
    let theme: Theme
    let typography: Typography
    let metrics: Metrics
    let onApply: (Int) -> Void

    @State private var appear = false
    @State private var dragY: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black.opacity(appear ? 0.55 : 0.0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                sheet
                    .frame(maxWidth: metrics.maxW)
                    .padding(.horizontal, metrics.side)
                    .padding(.bottom, metrics.bottomPad)
                    .offset(y: max(0, dragY) + (appear ? 0 : 34))
                    .opacity(appear ? 1 : 0)
                    .animation(.spring(response: 0.36, dampingFraction: 0.92), value: appear)
                    .animation(.spring(response: 0.30, dampingFraction: 0.92), value: dragY)
                    .gesture(
                        DragGesture(minimumDistance: 6, coordinateSpace: .global)
                            .onChanged { value in
                                let dy = value.translation.height
                                dragY = dy > 0 ? dy : 0
                            }
                            .onEnded { value in
                                let dy = value.translation.height
                                let shouldClose = dy > 120 || value.predictedEndTranslation.height > 180
                                if shouldClose { dismiss() } else { dragY = 0 }
                            }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            draft = min(draft, maxAllowed)
            selected = min(selected, maxAllowed)
            dragY = 0
            appear = false
            withAnimation(.spring(response: 0.36, dampingFraction: 0.92)) { appear = true }
        }
    }

    private var sheet: some View {
        VStack(spacing: 12) {
            header

            HStack(spacing: 10) {
                pill(title: "Current", value: formatCoins(selected))
                pill(title: "Draft", value: formatCoins(draft))
            }

            grid

            footer
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: metrics.corner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            theme.panelFill.opacity(0.98),
                            theme.panelFill2.opacity(0.99),
                            theme.panelFill.opacity(0.96)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: metrics.corner, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [theme.strokeA.opacity(0.95), theme.strokeB.opacity(0.70)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.6
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: max(8, metrics.corner - 6), style: .continuous)
                .stroke(theme.glow.opacity(0.16), lineWidth: 1)
                .padding(6)
        )
        .shadow(color: Color.black.opacity(0.45), radius: 26, x: 0, y: 14)
    }

    private var header: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Select Bet")
                    .font(typography.font(18))
                    .foregroundColor(theme.gold)
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 6)

                Text("Max \(formatCoins(maxAllowed))")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.dim.opacity(0.95))
            }

            Spacer(minLength: 0)

            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.22))
                        .frame(width: 34, height: 34)
                    Circle().stroke(theme.strokeB.opacity(0.12), lineWidth: 1)
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(theme.text.opacity(0.92))
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func pill(title: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(theme.dim.opacity(0.95))

            Text(value)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Capsule(style: .continuous).fill(Color.black.opacity(0.18)))
        .overlay(Capsule(style: .continuous).stroke(theme.strokeA.opacity(0.14), lineWidth: 1))
    }

    private var grid: some View {
        let cols: [GridItem] = [
            GridItem(.flexible(), spacing: metrics.gridGap),
            GridItem(.flexible(), spacing: metrics.gridGap),
            GridItem(.flexible(), spacing: metrics.gridGap)
        ]

        return LazyVGrid(columns: cols, spacing: metrics.gridGap) {
            ForEach(bets, id: \.self) { value in
                BetChip(
                    title: formatCoins(value),
                    isSelected: value == draft,
                    isEnabled: value <= maxAllowed,
                    h: metrics.chipH,
                    corner: metrics.chipCorner,
                    theme: theme,
                    typography: typography
                ) {
                    guard value <= maxAllowed else {
                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        return
                    }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    draft = value
                }
            }
        }
        .padding(.top, 2)
    }

    private var footer: some View {
        HStack(spacing: 10) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                draft = min(selected, maxAllowed)
            } label: {
                Capsule(style: .continuous)
                    .fill(Color.black.opacity(0.18))
                    .overlay(Capsule(style: .continuous).stroke(theme.strokeB.opacity(0.12), lineWidth: 1))
                    .overlay(
                        HStack(spacing: 7) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 12, weight: .black))
                            Text("Reset")
                                .font(typography.font(14))
                        }
                        .foregroundColor(theme.text.opacity(0.92))
                    )
            }
            .buttonStyle(.plain)
            .frame(height: 46)

            Button {
                let v = min(draft, maxAllowed)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onApply(v)
                dismiss()
            } label: {
                Capsule(style: .continuous)
                    .fill(LinearGradient(colors: [theme.strokeA, theme.strokeB], startPoint: .leading, endPoint: .trailing))
                    .overlay(Capsule(style: .continuous).stroke(theme.gold.opacity(0.75), lineWidth: 1.4))
                    .overlay(
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .black))
                            Text("Apply \(formatCoins(min(draft, maxAllowed)))")
                                .font(typography.font(14))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .foregroundColor(.black.opacity(0.82))
                    )
            }
            .buttonStyle(.plain)
            .frame(height: 46)
        }
        .padding(.top, 4)
    }

    private func dismiss() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.easeOut(duration: 0.16)) { appear = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            dragY = 0
            isPresented = false
        }
    }
}

private struct BetChip: View {
    let title: String
    let isSelected: Bool
    let isEnabled: Bool
    let h: CGFloat
    let corner: CGFloat
    let theme: BetSheetOverlay.Theme
    let typography: BetSheetOverlay.Typography
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Capsule(style: .continuous)
                    .fill(
                        isSelected
                        ? LinearGradient(
                            colors: [theme.strokeA.opacity(0.95), theme.strokeB.opacity(0.90)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [theme.panelFill2.opacity(0.96), theme.panelFill.opacity(0.92)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Capsule(style: .continuous)
                    .stroke(
                        isSelected ? theme.gold.opacity(0.75) : theme.strokeB.opacity(0.10),
                        lineWidth: isSelected ? 1.6 : 1.0
                    )

                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(isSelected ? 0.16 : 0.22))
                            .frame(width: 22, height: 22)
                        Image(systemName: isSelected ? "sparkles" : "circle.fill")
                            .font(.system(size: isSelected ? 11 : 7, weight: .black))
                            .foregroundColor(isSelected ? Color.black.opacity(0.82) : theme.warm.opacity(0.90))
                    }

                    Text(title)
                        .font(typography.font(14))
                        .foregroundColor(isSelected ? Color.black.opacity(0.82) : theme.text.opacity(isEnabled ? 0.92 : 0.35))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
            }
            .opacity(isEnabled ? 1.0 : 0.65)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .frame(height: h)
    }
}

private enum PokerBotBrain {
    static func estimateStrength(hole: [PokerCard], allCards: [PokerCard], phase: GamePokerView.TablePhase) -> Double {
        if allCards.count >= 5 {
            let best = PokerEvaluator.bestHand(from: allCards)
            let catScore = Double(best.category.rawValue) / Double(PokerHandCategory.royalFlush.rawValue)

            let kickerScore = best.primaryRanks.prefix(2).enumerated().reduce(0.0) { partial, pair in
                partial + (Double(pair.element.rawValue) / 14.0) * (pair.offset == 0 ? 0.20 : 0.10)
            }

            return min(1.0, 0.35 + catScore * 0.55 + kickerScore)
        }

        guard hole.count == 2 else { return 0.2 }
        let a = hole[0]
        let b = hole[1]

        let pair = a.rank == b.rank
        let suited = a.suit == b.suit
        let high = max(a.rank.rawValue, b.rank.rawValue)
        let low = min(a.rank.rawValue, b.rank.rawValue)
        let connected = abs(a.rank.rawValue - b.rank.rawValue) <= 1

        var score = 0.18
        if pair { score += 0.38 + Double(high) / 40.0 }
        if suited { score += 0.10 }
        if connected { score += 0.08 }
        if high >= 12 { score += 0.12 }
        if low >= 10 { score += 0.08 }

        return min(1.0, score)
    }
}

private struct PokerCard: Hashable, Equatable {
    let rank: PokerRank
    let suit: PokerSuit
}

private enum PokerSuit: CaseIterable, Hashable {
    case hearts
    case diamonds
    case clubs
    case spades

    var symbol: String {
        switch self {
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        case .spades: return "♠"
        }
    }

    var isRed: Bool {
        switch self {
        case .hearts, .diamonds: return true
        case .clubs, .spades: return false
        }
    }
}

private enum PokerRank: Int, CaseIterable, Comparable, Hashable {
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case jack = 11
    case queen = 12
    case king = 13
    case ace = 14

    var label: String {
        switch self {
        case .ace: return "A"
        case .king: return "K"
        case .queen: return "Q"
        case .jack: return "J"
        case .ten: return "10"
        case .nine: return "9"
        case .eight: return "8"
        case .seven: return "7"
        case .six: return "6"
        case .five: return "5"
        case .four: return "4"
        case .three: return "3"
        case .two: return "2"
        }
    }

    static func < (lhs: PokerRank, rhs: PokerRank) -> Bool { lhs.rawValue < rhs.rawValue }
}

private enum PokerDeck {
    static func shuffled() -> [PokerCard] {
        var deck: [PokerCard] = []
        for suit in PokerSuit.allCases {
            for rank in PokerRank.allCases {
                deck.append(PokerCard(rank: rank, suit: suit))
            }
        }
        return deck.shuffled()
    }
}

private enum PokerHandCategory: Int, Comparable {
    case highCard = 0
    case pair = 1
    case twoPair = 2
    case threeKind = 3
    case straight = 4
    case flush = 5
    case fullHouse = 6
    case fourKind = 7
    case straightFlush = 8
    case royalFlush = 9

    var displayName: String {
        switch self {
        case .highCard: return "High Card"
        case .pair: return "Pair"
        case .twoPair: return "Two Pair"
        case .threeKind: return "Three of a Kind"
        case .straight: return "Straight"
        case .flush: return "Flush"
        case .fullHouse: return "Full House"
        case .fourKind: return "Four of a Kind"
        case .straightFlush: return "Straight Flush"
        case .royalFlush: return "Royal Flush"
        }
    }

    static func < (lhs: PokerHandCategory, rhs: PokerHandCategory) -> Bool { lhs.rawValue < rhs.rawValue }
}

private struct PokerHandValue: Comparable, Equatable {
    let category: PokerHandCategory
    let primaryRanks: [PokerRank]

    static func < (lhs: PokerHandValue, rhs: PokerHandValue) -> Bool {
        if lhs.category != rhs.category { return lhs.category < rhs.category }

        let maxCount = max(lhs.primaryRanks.count, rhs.primaryRanks.count)
        for i in 0..<maxCount {
            let l = i < lhs.primaryRanks.count ? lhs.primaryRanks[i].rawValue : 0
            let r = i < rhs.primaryRanks.count ? rhs.primaryRanks[i].rawValue : 0
            if l != r { return l < r }
        }
        return false
    }
}

private enum PokerEvaluator {
    static func bestHand(from cards: [PokerCard]) -> PokerHandValue {
        let valid = cards
        if valid.count < 5 { return PokerHandValue(category: .highCard, primaryRanks: []) }

        var best: PokerHandValue?
        let n = valid.count

        for a in 0..<(n - 4) {
            for b in (a + 1)..<(n - 3) {
                for c in (b + 1)..<(n - 2) {
                    for d in (c + 1)..<(n - 1) {
                        for e in (d + 1)..<n {
                            let hand = [valid[a], valid[b], valid[c], valid[d], valid[e]]
                            let value = evaluateFive(hand)
                            if let bestValue = best {
                                if value > bestValue { best = value }
                            } else {
                                best = value
                            }
                        }
                    }
                }
            }
        }

        return best ?? PokerHandValue(category: .highCard, primaryRanks: [])
    }

    private static func evaluateFive(_ cards: [PokerCard]) -> PokerHandValue {
        let sortedRanksDesc = cards.map(\.rank).sorted(by: >)
        let rankCounts = Dictionary(grouping: cards.map(\.rank), by: { $0 }).mapValues(\.count)
        let suitCounts = Dictionary(grouping: cards.map(\.suit), by: { $0 }).mapValues(\.count)

        let isFlush = suitCounts.values.contains(5)
        let straightHigh = straightHighRank(cards.map(\.rank))

        if isFlush, let straightHigh {
            if straightHigh == .ace && Set(cards.map(\.rank)) == Set([.ten, .jack, .queen, .king, .ace]) {
                return PokerHandValue(category: .royalFlush, primaryRanks: [.ace])
            }
            return PokerHandValue(category: .straightFlush, primaryRanks: [straightHigh])
        }

        let groups = rankCounts
            .map { (rank: $0.key, count: $0.value) }
            .sorted {
                if $0.count != $1.count { return $0.count > $1.count }
                return $0.rank.rawValue > $1.rank.rawValue
            }

        if groups[0].count == 4 {
            let four = groups[0].rank
            let kicker = groups.first(where: { $0.count == 1 })?.rank ?? .two
            return PokerHandValue(category: .fourKind, primaryRanks: [four, kicker])
        }

        if groups[0].count == 3, groups.count > 1, groups[1].count == 2 {
            return PokerHandValue(category: .fullHouse, primaryRanks: [groups[0].rank, groups[1].rank])
        }

        if isFlush { return PokerHandValue(category: .flush, primaryRanks: sortedRanksDesc) }
        if let straightHigh { return PokerHandValue(category: .straight, primaryRanks: [straightHigh]) }

        if groups[0].count == 3 {
            let trips = groups[0].rank
            let kickers = groups.filter { $0.count == 1 }.map(\.rank).sorted(by: >)
            return PokerHandValue(category: .threeKind, primaryRanks: [trips] + kickers)
        }

        let pairs = groups.filter { $0.count == 2 }.map(\.rank).sorted(by: >)
        if pairs.count >= 2 {
            let topTwo = Array(pairs.prefix(2))
            let kicker = groups.first(where: { $0.count == 1 })?.rank ?? .two
            return PokerHandValue(category: .twoPair, primaryRanks: topTwo + [kicker])
        }

        if let pair = groups.first(where: { $0.count == 2 })?.rank {
            let kickers = groups.filter { $0.count == 1 }.map(\.rank).sorted(by: >)
            return PokerHandValue(category: .pair, primaryRanks: [pair] + kickers)
        }

        return PokerHandValue(category: .highCard, primaryRanks: sortedRanksDesc)
    }

    private static func straightHighRank(_ ranks: [PokerRank]) -> PokerRank? {
        let unique = Array(Set(ranks.map(\.rawValue))).sorted()
        guard unique.count == 5 else { return nil }

        if unique == [2, 3, 4, 5, 14] { return .five }

        let minV = unique.first ?? 0
        let maxV = unique.last ?? 0
        guard maxV - minV == 4 else { return nil }

        return PokerRank(rawValue: maxV)
    }
}
