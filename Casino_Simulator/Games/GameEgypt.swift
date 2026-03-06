// Path: Games/GameEgypt.swift

import SwiftUI
import UIKit

struct GameEgyptView: View {
    let game: GameCasProfSt.CasinoMode
    let onClose: () -> Void

    @EnvironmentObject private var profile: GameCasProfSt

    @State private var bet: Int = 300
    @State private var isSpinning: Bool = false
    @State private var showBetSheet: Bool = false

    @State private var reel1: EgyptReelToken = .init()
    @State private var reel2: EgyptReelToken = .init()
    @State private var reel3: EgyptReelToken = .init()

    @State private var lastOutcome: GameCasProfSt.SpinResolution? = nil

    @State private var winPaylines: [EgyptPayline] = []
    @State private var showPaylines: Bool = false
    @State private var activePaylineIndex: Int = 0
    @State private var paylinesLoopId: UUID = UUID()

    @State private var bannerText: String = ""
    @State private var bannerVisible: Bool = false
    @State private var bannerFade: CGFloat = 1.0
    @State private var bannerTaskId: UUID = UUID()

    private enum Assets {
        static let background = "back_egypt"
        static let title = "egypt_title"
        static let spin = "btn_spin"
    }

    private enum Palette {
        static let blockFill = Color(hex: "3E1601")
        static let innerFill = Color(hex: "2A0F02")

        static let strokeA = Color(hex: "E18919")
        static let strokeB = Color(hex: "883C0E")

        static let divider = Color(hex: "A95A18")
        static let text = Color(hex: "FCE7B6")

        static let glow = Color(hex: "FFD98A")
        static let win = Color(hex: "FFD06E")
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

        struct Metrics {
            let sideInset: CGFloat
            let topInset: CGFloat
            let globalDownShift: CGFloat

            let titleTopGap: CGFloat
            let titleHeight: CGFloat

            let slotTopGap: CGFloat
            let slotCorner: CGFloat
            let slotStroke: CGFloat

            let reelSeparatorW: CGFloat
            let reelPadH: CGFloat
            let reelPadV: CGFloat

            let visibleRows: Int
            let rowGap: CGFloat

            let bottomTopGap: CGFloat
            let bottomCorner: CGFloat
            let bottomStroke: CGFloat
            let bottomHeight: CGFloat
            let bottomInnerPad: CGFloat

            let betW: CGFloat
            let betCorner: CGFloat
            let betStroke: CGFloat
            let betText: CGFloat

            let amountCorner: CGFloat
            let amountStroke: CGFloat
            let amountText: CGFloat

            let spinW: CGFloat
            let spinH: CGFloat

            let bottomHSpacing: CGFloat

            let bannerHeight: CGFloat
            let bannerCorner: CGFloat
            let bannerStroke: CGFloat
            let bannerTextSize: CGFloat
            let bannerBottomInset: CGFloat
            let bannerSideInset: CGFloat
            let backButtonTopGap: CGFloat
            let backButtonWidth: CGFloat
            let backButtonHeight: CGFloat
            let backButtonCorner: CGFloat
            let backButtonStroke: CGFloat
            let backButtonTextSize: CGFloat
        }

        static let compact = Metrics(
            sideInset: 22,
            topInset: 14,
            globalDownShift: 10,

            titleTopGap: 8,
            titleHeight: 32,

            slotTopGap: 10,
            slotCorner: 22,
            slotStroke: 5.2,

            reelSeparatorW: 3,
            reelPadH: 12,
            reelPadV: 12,

            visibleRows: 4,
            rowGap: 12,

            bottomTopGap: 8,
            bottomCorner: 16,
            bottomStroke: 3,
            bottomHeight: 40,
            bottomInnerPad: 6,

            betW: 62,
            betCorner: 14,
            betStroke: 2.5,
            betText: 14,

            amountCorner: 16,
            amountStroke: 2.5,
            amountText: 18,

            spinW: 84,
            spinH: 32,

            bottomHSpacing: 8,

            bannerHeight: 30,
            bannerCorner: 14,
            bannerStroke: 2.5,
            bannerTextSize: 14,
            bannerBottomInset: 10,
            bannerSideInset: 12,
            backButtonTopGap: 10,
            backButtonWidth: 116,
            backButtonHeight: 36,
            backButtonCorner: 16,
            backButtonStroke: 2.5,
            backButtonTextSize: 15
        )

        static let regular = Metrics(
            sideInset: 28,
            topInset: 18,
            globalDownShift: 14,

            titleTopGap: 10,
            titleHeight: 36,

            slotTopGap: 12,
            slotCorner: 24,
            slotStroke: 6.0,

            reelSeparatorW: 3,
            reelPadH: 14,
            reelPadV: 14,

            visibleRows: 4,
            rowGap: 14,

            bottomTopGap: 10,
            bottomCorner: 18,
            bottomStroke: 3.5,
            bottomHeight: 44,
            bottomInnerPad: 7,

            betW: 70,
            betCorner: 15,
            betStroke: 2.8,
            betText: 15,

            amountCorner: 18,
            amountStroke: 2.8,
            amountText: 20,

            spinW: 96,
            spinH: 36,

            bottomHSpacing: 10,

            bannerHeight: 34,
            bannerCorner: 16,
            bannerStroke: 2.8,
            bannerTextSize: 15,
            bannerBottomInset: 12,
            bannerSideInset: 14,
            backButtonTopGap: 12,
            backButtonWidth: 124,
            backButtonHeight: 40,
            backButtonCorner: 18,
            backButtonStroke: 2.8,
            backButtonTextSize: 16
        )

        static func metrics(forWidth w: CGFloat) -> Metrics { isCompact(w) ? compact : regular }
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let m = Layout.metrics(forWidth: w)

            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom

            let contentW = max(0, w - (m.sideInset * 2))
            let reelsW = max(0, contentW - (m.reelPadH * 2) - (m.reelSeparatorW * 2))
            let oneReelW = floor(reelsW / 3.0)

            let maxSlotH = max(
                0,
                h
                - safeTop - safeBottom
                - (m.topInset + m.globalDownShift + m.titleTopGap + m.titleHeight + m.slotTopGap + m.bottomTopGap + m.bottomHeight + m.backButtonTopGap + m.backButtonHeight)
                - 18
            )
            let targetSlotH = min(maxSlotH, h * 0.56)

            let slotInnerH = max(0, targetSlotH - (m.reelPadV * 2) - m.slotStroke)
            let symbolSizeByWidth = max(40, floor(oneReelW * 0.86))
            let symbolSizeByHeight = max(40, floor((slotInnerH - (CGFloat(m.visibleRows - 1) * m.rowGap)) / CGFloat(m.visibleRows)))
            let symbolSize = min(symbolSizeByWidth, symbolSizeByHeight)

            ZStack {
                Image(Assets.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    TopHUDView(onOpenProfile: onClose)
                        .padding(.top, m.topInset)
                        .frame(width: contentW)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Image(Assets.title)
                        .resizable()
                        .scaledToFit()
                        .frame(height: m.titleHeight)
                        .padding(.top, m.titleTopGap)
                        .frame(width: contentW)
                        .frame(maxWidth: .infinity, alignment: .center)

                    slotBlock(
                        m: m,
                        contentW: contentW,
                        reelW: oneReelW,
                        symbolSize: symbolSize,
                        targetSlotH: targetSlotH
                    )
                    .padding(.top, m.slotTopGap)
                    .frame(maxWidth: .infinity, alignment: .center)

                    bottomPanel(m: m, contentW: contentW)
                        .padding(.top, m.bottomTopGap)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Button {
                        onClose()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: m.backButtonCorner, style: .continuous)
                                .fill(Palette.innerFill.opacity(0.94))

                            RoundedRectangle(cornerRadius: m.backButtonCorner, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        stops: [
                                            .init(color: Palette.strokeA, location: 0.0),
                                            .init(color: Palette.strokeB, location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: m.backButtonStroke
                                )

                            Text("Back")
                                .font(Typography.font(size: m.backButtonTextSize))
                                .foregroundColor(Palette.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(width: m.backButtonWidth, height: m.backButtonHeight)
                        .shadow(color: Palette.strokeA.opacity(0.18), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, m.backButtonTopGap)

                    Spacer(minLength: 0)
                }
                .padding(.top, m.globalDownShift)
            }
            .sheet(isPresented: $showBetSheet) {
                BetPickerSheet(
                    coins: profile.coins,
                    currentBet: bet,
                    minBet: 100,
                    onApply: { newBet in
                        bet = profile.normalizedBet(newBet, minBet: 100)
                    }
                )
                .applyMediumDetentIfAvailable()
            }
            .onAppear {
                bet = min(max(300, 100), max(100, profile.coins))
                if reel1.finalWindow.isEmpty {
                    let start = SlotSymbol.safeDefaultWindow(rows: 4)
                    reel1 = EgyptReelToken(spins: 0, duration: 0, finalWindow: start)
                    reel2 = EgyptReelToken(spins: 0, duration: 0, finalWindow: start)
                    reel3 = EgyptReelToken(spins: 0, duration: 0, finalWindow: start)
                }
            }
        }
    }

    @ViewBuilder
    private func slotBlock(
        m: Layout.Metrics,
        contentW: CGFloat,
        reelW: CGFloat,
        symbolSize: CGFloat,
        targetSlotH: CGFloat
    ) -> some View {
        let outer = RoundedRectangle(cornerRadius: m.slotCorner, style: .continuous)
        let innerCorner = max(0, m.slotCorner - (m.slotStroke * 0.55))
        let glowPad = max(12, symbolSize * 0.26)

        ZStack {
            outer.fill(Palette.blockFill)

            outer.strokeBorder(
                LinearGradient(
                    stops: [
                        .init(color: Palette.strokeA, location: 0.0),
                        .init(color: Palette.strokeB, location: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: m.slotStroke
            )

            reelsArea(
                m: m,
                reelW: reelW,
                symbolSize: symbolSize,
                innerCorner: innerCorner,
                glowPad: glowPad
            )
        }
        .frame(width: contentW, height: targetSlotH)
        .overlay(alignment: .bottom) {
            comboBanner(m: m)
                .padding(.horizontal, m.bannerSideInset)
                .padding(.bottom, m.bannerBottomInset)
                .allowsHitTesting(false)
        }
    }

    private func reelsArea(
        m: Layout.Metrics,
        reelW: CGFloat,
        symbolSize: CGFloat,
        innerCorner: CGFloat,
        glowPad: CGFloat
    ) -> some View {
        let reels = HStack(spacing: 0) {
            EgyptReelView(
                reelIndex: 0,
                token: $reel1,
                reelWidth: reelW,
                symbolSize: symbolSize,
                visibleRows: m.visibleRows,
                rowGap: m.rowGap
            )

            Rectangle()
                .fill(Palette.divider.opacity(0.95))
                .frame(width: m.reelSeparatorW)
                .padding(.vertical, 6)

            EgyptReelView(
                reelIndex: 1,
                token: $reel2,
                reelWidth: reelW,
                symbolSize: symbolSize,
                visibleRows: m.visibleRows,
                rowGap: m.rowGap
            )

            Rectangle()
                .fill(Palette.divider.opacity(0.95))
                .frame(width: m.reelSeparatorW)
                .padding(.vertical, 6)

            EgyptReelView(
                reelIndex: 2,
                token: $reel3,
                reelWidth: reelW,
                symbolSize: symbolSize,
                visibleRows: m.visibleRows,
                rowGap: m.rowGap
            )
        }
        .padding(.horizontal, m.reelPadH)
        .padding(.vertical, m.reelPadV)
        .padding(m.slotStroke * 0.5)

        return reels
            .background(
                GeometryReader { gp in
                    Color.clear
                        .overlayPreferenceValue(EgyptSymbolBoundsPreferenceKey.self) { anchors in
                            EgyptPaylineGlowBehindSymbols(
                                anchors: anchors,
                                paylines: showPaylines ? winPaylines : [],
                                activeIndex: activePaylineIndex,
                                isWinning: (lastOutcome?.multiplier ?? 0) >= 1.5,
                                symbolSize: symbolSize
                            )
                            .padding(glowPad)
                            .frame(width: gp.size.width, height: gp.size.height)
                            .mask(
                                RoundedRectangle(cornerRadius: innerCorner, style: .continuous)
                                    .padding(glowPad)
                            )
                            .allowsHitTesting(false)
                        }
                }
            )
            .mask(
                RoundedRectangle(cornerRadius: innerCorner, style: .continuous)
                    .padding(m.slotStroke * 0.55)
            )
    }

    @ViewBuilder
    private func comboBanner(m: Layout.Metrics) -> some View {
        if bannerVisible {
            let outer = RoundedRectangle(cornerRadius: m.bannerCorner, style: .continuous)

            ZStack {
                outer.fill(Palette.innerFill.opacity(0.92))

                outer.strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: Palette.strokeA, location: 0.0),
                            .init(color: Palette.strokeB, location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: m.bannerStroke
                )

                Text(bannerText)
                    .font(Typography.font(size: m.bannerTextSize))
                    .foregroundColor(Palette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .opacity(bannerFade)
                    .padding(.horizontal, 12)
            }
            .frame(height: m.bannerHeight)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private func bottomPanel(m: Layout.Metrics, contentW: CGFloat) -> some View {
        let outer = RoundedRectangle(cornerRadius: m.bottomCorner, style: .continuous)
        let amountW: CGFloat = max(140, floor(contentW * 0.40))
        let innerH = m.bottomHeight - (m.bottomInnerPad * 2)

        ZStack {
            outer.fill(Palette.blockFill)

            outer.strokeBorder(
                LinearGradient(
                    stops: [
                        .init(color: Palette.strokeA, location: 0.0),
                        .init(color: Palette.strokeB, location: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: m.bottomStroke
            )

            HStack(spacing: m.bottomHSpacing) {
                Button {
                    guard !isSpinning else { return }
                    showBetSheet = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: m.betCorner, style: .continuous)
                            .fill(Palette.innerFill)

                        RoundedRectangle(cornerRadius: m.betCorner, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    stops: [
                                        .init(color: Palette.strokeA, location: 0.0),
                                        .init(color: Palette.strokeB, location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: m.betStroke
                            )

                        Text("Bet")
                            .font(Typography.font(size: m.betText))
                            .foregroundColor(Palette.text)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .buttonStyle(.plain)
                .frame(width: m.betW, height: innerH)

                ZStack {
                    RoundedRectangle(cornerRadius: m.amountCorner, style: .continuous)
                        .fill(Palette.innerFill)

                    RoundedRectangle(cornerRadius: m.amountCorner, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Palette.strokeA, location: 0.0),
                                    .init(color: Palette.strokeB, location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: m.amountStroke
                        )

                    Text(Self.formatNumber(bet))
                        .font(Typography.font(size: m.amountText))
                        .foregroundColor(Palette.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
                .frame(width: amountW, height: innerH)

                Button { spin() } label: {
                    Image(Assets.spin)
                        .resizable()
                        .scaledToFit()
                        .frame(width: m.spinW, height: m.spinH)
                }
                .buttonStyle(.plain)
                .disabled(isSpinning || bet <= 0 || bet > profile.coins)
                .opacity((isSpinning || bet <= 0 || bet > profile.coins) ? 0.7 : 1.0)
            }
            .padding(.horizontal, m.bottomInnerPad)
            .padding(.vertical, m.bottomInnerPad)
        }
        .frame(width: contentW, height: m.bottomHeight)
    }

    private func spin() {
        guard !isSpinning else { return }

        stopPaylinesLoop()
        hideBanner()

        bet = profile.normalizedBet(bet, minBet: 100)
        guard bet <= profile.coins else { return }

        isSpinning = true
        showBanner(text: "Bet  -\(Self.formatNumber(bet))", autoHideAfter: 1.6)

        let total = Double.random(in: 3.0...10.0)
        let r1 = max(2.6, total * 0.82)
        let r2 = max(2.9, total * 0.92)
        let r3 = total

        let outcome = profile.spin(mode: game, bet: bet, minBet: 100)
        lastOutcome = outcome

        let full = outcome?.symbols ?? SlotSymbol.safeDefaultWindow(rows: 12)
        let rows = 4

        let w1 = Array(full[0..<rows])
        let w2 = Array(full[rows..<(2 * rows)])
        let w3 = Array(full[(2 * rows)..<(3 * rows)])

        reel1 = EgyptReelToken(spins: spinsCount(for: r1), duration: r1, finalWindow: w1)
        reel2 = EgyptReelToken(spins: spinsCount(for: r2), duration: r2, finalWindow: w2)
        reel3 = EgyptReelToken(spins: spinsCount(for: r3), duration: r3, finalWindow: w3)

        Task { @MainActor in
            let maxDur = max(reel1.duration, reel2.duration, reel3.duration)
            try? await Task.sleep(nanoseconds: UInt64((maxDur + 0.28) * 1_000_000_000))

            isSpinning = false

            computeAndShowPaylines(rows: rows, c0: w1, c1: w2, c2: w3)

            if bet > profile.coins {
                bet = max(100, min(300, profile.coins))
            }
        }
    }

    private func spinsCount(for duration: Double) -> Int {
        let t = max(0, min(1, (duration - 3.0) / 7.0))
        let base = 24.0 + (58.0 - 24.0) * t
        let jitter = Double.random(in: -3.0...3.0)
        return max(18, Int((base + jitter).rounded()))
    }

    private func computeAndShowPaylines(rows: Int, c0: [SlotSymbol], c1: [SlotSymbol], c2: [SlotSymbol]) {
        let grid = EgyptSlotGrid(rows: rows, col0: c0, col1: c1, col2: c2)
        let all = EgyptPayline.defaults(forRows: rows)
        let wins = all.filter { $0.isWin(in: grid) }

        if wins.isEmpty {
            winPaylines = []
            withAnimation(.easeOut(duration: 0.18)) { showPaylines = false }
            showNoWinBanner()
            return
        }

        winPaylines = wins
        activePaylineIndex = 0
        withAnimation(.easeOut(duration: 0.18)) { showPaylines = true }
        showWinBanner(for: grid, paylineIndex: 0)
        startPaylinesLoop(grid: grid)
    }

    private func startPaylinesLoop(grid: EgyptSlotGrid) {
        let id = UUID()
        paylinesLoopId = id

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(0.22 * 1_000_000_000))
            guard paylinesLoopId == id else { return }

            while showPaylines && paylinesLoopId == id {
                try? await Task.sleep(nanoseconds: UInt64(1.35 * 1_000_000_000))
                guard paylinesLoopId == id else { return }
                if winPaylines.count <= 1 { continue }

                withAnimation(.easeInOut(duration: 0.24)) {
                    activePaylineIndex = (activePaylineIndex + 1) % winPaylines.count
                }
                showWinBanner(for: grid, paylineIndex: activePaylineIndex)
            }
        }
    }

    private func stopPaylinesLoop() {
        paylinesLoopId = UUID()
        withAnimation(.easeOut(duration: 0.18)) { showPaylines = false }
        winPaylines = []
        activePaylineIndex = 0
    }

    private func showWinBanner(for grid: EgyptSlotGrid, paylineIndex: Int) {
        guard winPaylines.indices.contains(paylineIndex) else { return }
        let line = winPaylines[paylineIndex]
        guard line.rowsByReel.count == 3 else { return }

        guard
            let a = grid.symbol(col: 0, row: line.rowsByReel[0]),
            let b = grid.symbol(col: 1, row: line.rowsByReel[1]),
            let c = grid.symbol(col: 2, row: line.rowsByReel[2]),
            a == b, b == c
        else { return }

        let multiplier = lastOutcome?.multiplier ?? 0
        let payout = lastOutcome?.payout ?? 0
        let net = lastOutcome?.delta ?? 0

        let title = comboTitle(for: a, multiplier: multiplier)

        if payout > 0 {
            showBanner(text: "\(title)  +\(Self.formatNumber(payout))", autoHideAfter: 3.0)
        } else if net < 0 {
            showBanner(text: "\(title)  -\(Self.formatNumber(abs(net)))", autoHideAfter: 2.6)
        } else {
            showBanner(text: "\(title)", autoHideAfter: 2.6)
        }
    }

    private func showNoWinBanner() {
        let net = lastOutcome?.delta ?? 0
        if net < 0 {
            showBanner(text: "No combo  -\(Self.formatNumber(abs(net)))", autoHideAfter: 2.4)
        } else if net == 0 {
            showBanner(text: "No combo", autoHideAfter: 2.3)
        } else {
            showBanner(text: "No combo  +\(Self.formatNumber(net))", autoHideAfter: 2.4)
        }
    }

    private func showBanner(text: String, autoHideAfter seconds: TimeInterval) {
        let id = UUID()
        bannerTaskId = id

        if bannerVisible {
            withAnimation(.easeOut(duration: 0.18)) { bannerFade = 0.0 }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(0.18 * 1_000_000_000))
                guard bannerTaskId == id else { return }
                bannerText = text
                withAnimation(.easeIn(duration: 0.20)) { bannerFade = 1.0 }
            }
        } else {
            bannerText = text
            bannerFade = 1.0
            withAnimation(.spring(response: 0.55, dampingFraction: 0.88)) {
                bannerVisible = true
            }
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(max(0.6, seconds) * 1_000_000_000))
            guard bannerTaskId == id else { return }
            withAnimation(.easeInOut(duration: 0.44)) { bannerVisible = false }
        }
    }

    private func hideBanner() {
        bannerTaskId = UUID()
        withAnimation(.easeOut(duration: 0.16)) { bannerVisible = false }
    }

    private func comboTitle(for symbol: SlotSymbol, multiplier: Double) -> String {
        if multiplier >= 50 { return "PHARAOH JACKPOT x50" }
        if multiplier >= 10 { return "RA TREASURE x10" }
        if multiplier >= 3 { return "EGYPT COMBO x3" }
        if multiplier >= 1.5 { return "EGYPT WIN" }

        switch symbol {
        case .three: return "Pyramids"
        case .bell: return "Horus Eyes"
        case .strawberry: return "Sun Disks"
        case .cherry: return "Pharaoh Hands"
        case .watermelon: return "Golden Pyramids"
        case .grape: return "Relics"
        }
    }

    private static func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

private struct EgyptReelToken: Equatable {
    let id: UUID
    let spins: Int
    let duration: TimeInterval
    let finalWindow: [SlotSymbol]

    init(spins: Int = 0, duration: TimeInterval = 0, finalWindow: [SlotSymbol] = []) {
        self.id = UUID()
        self.spins = spins
        self.duration = duration
        self.finalWindow = finalWindow
    }
}

private struct EgyptSymbolCellKey: Hashable {
    let reel: Int
    let row: Int
}

private struct EgyptSymbolBoundsPreferenceKey: PreferenceKey {
    static var defaultValue: [EgyptSymbolCellKey: Anchor<CGRect>] = [:]

    static func reduce(value: inout [EgyptSymbolCellKey: Anchor<CGRect>], nextValue: () -> [EgyptSymbolCellKey: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

private struct EgyptPaylineGlowBehindSymbols: View {
    let anchors: [EgyptSymbolCellKey: Anchor<CGRect>]
    let paylines: [EgyptPayline]
    let activeIndex: Int
    let isWinning: Bool
    let symbolSize: CGFloat

    @State private var floatOn: Bool = false

    private enum Palette {
        static let glow = Color(hex: "FFE7B0")
        static let core = Color(hex: "E18919")
        static let win = Color(hex: "FFD06E")
    }

    var body: some View {
        GeometryReader { gp in
            ZStack {
                if let p = activePayline, p.rowsByReel.count == 3 {
                    let floatY: CGFloat = floatOn ? -2.0 : 2.0
                    let baseColor = isWinning ? Palette.win : Palette.core
                    let corner = max(12, symbolSize * 0.28)

                    ForEach(0..<3, id: \.self) { reel in
                        let row = p.rowsByReel[reel]
                        let key = EgyptSymbolCellKey(reel: reel, row: row)
                        if let a = anchors[key] {
                            let rect = gp[a]
                            let w = rect.width * 1.04
                            let h = rect.height * 1.04

                            RoundedRectangle(cornerRadius: corner, style: .continuous)
                                .fill(baseColor.opacity(0.22))
                                .frame(width: w, height: h)
                                .position(x: rect.midX, y: rect.midY + floatY)
                                .blur(radius: max(16, symbolSize * 0.28))

                            RoundedRectangle(cornerRadius: corner, style: .continuous)
                                .fill(Palette.glow.opacity(0.17))
                                .frame(width: w * 0.92, height: h * 0.92)
                                .position(x: rect.midX, y: rect.midY + floatY)
                                .blur(radius: max(11, symbolSize * 0.20))

                            RoundedRectangle(cornerRadius: corner, style: .continuous)
                                .fill(baseColor.opacity(0.12))
                                .frame(width: w * 0.78, height: h * 0.78)
                                .position(x: rect.midX, y: rect.midY + floatY)
                                .blur(radius: max(8, symbolSize * 0.15))
                                .opacity(reel == 1 ? 1.0 : 0.92)
                        }
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.05).repeatForever(autoreverses: true)) {
                    floatOn = true
                }
            }
            .animation(.easeInOut(duration: 0.22), value: activeIndex)
        }
        .allowsHitTesting(false)
    }

    private var activePayline: EgyptPayline? {
        guard !paylines.isEmpty, paylines.indices.contains(activeIndex) else { return nil }
        return paylines[activeIndex]
    }
}

private struct EgyptReelView: View {
    let reelIndex: Int
    @Binding var token: EgyptReelToken

    let reelWidth: CGFloat
    let symbolSize: CGFloat
    let visibleRows: Int
    let rowGap: CGFloat

    @State private var base: [SlotSymbol] = []
    @State private var finalWindow: [SlotSymbol] = []

    @State private var startTime: TimeInterval = 0
    @State private var phase: Phase = .final
    @State private var finalOpacity: CGFloat = 1

    private enum Phase { case spinning, final }

    var body: some View {
        let step = symbolSize + rowGap
        let visibleH = (CGFloat(visibleRows) * symbolSize) + (CGFloat(visibleRows - 1) * rowGap)

        TimelineView(.animation) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let offset = computeOffset(t: t, step: step)

            ZStack {
                loopStrip(step: step, offset: offset)
                    .opacity(phase == .spinning ? 1 : 0)

                finalStrip()
                    .opacity(phase == .final ? finalOpacity : 0)
            }
            .frame(width: reelWidth, height: visibleH)
            .clipped()
            .onChange(of: token.id) { _ in
                startSpin(now: t)
            }
            .onAppear {
                prepareBase()
                prepareFinal()
                phase = .final
                finalOpacity = 1
            }
        }
    }

    private func prepareBase() {
        let baseCount = max(22, visibleRows * 6)
        let pool = SlotSymbol.availableCases
        base = (0..<baseCount).map { _ in pool.randomElement() ?? .watermelon }
    }

    private func prepareFinal() {
        if token.finalWindow.count == visibleRows {
            finalWindow = token.finalWindow
        } else {
            finalWindow = SlotSymbol.safeDefaultWindow(rows: visibleRows)
        }
    }

    private func startSpin(now: TimeInterval) {
        if base.isEmpty { prepareBase() }
        prepareFinal()
        startTime = now
        phase = .spinning
        finalOpacity = 1
    }

    private func computeOffset(t: TimeInterval, step: CGFloat) -> CGFloat {
        guard phase == .spinning else { return 0 }
        guard startTime > 0, !base.isEmpty else { return 0 }

        let loopHeight = CGFloat(base.count) * step
        let total = max(0.01, token.duration)

        let spinPart = total * 0.80
        let stopPart = total - spinPart
        let elapsed = max(0, t - startTime)

        if elapsed < spinPart {
            let speed = loopHeight / 0.58
            let raw = CGFloat(elapsed) * speed
            let mod = raw.truncatingRemainder(dividingBy: loopHeight)
            return -mod
        }

        let stopElapsed = min(stopPart, max(0, elapsed - spinPart))
        let p = min(1, stopElapsed / max(0.01, stopPart))
        let easeOut = 1 - pow(1 - CGFloat(p), 3)

        let targetTurns = CGFloat(max(10, token.spins))
        let distance = (targetTurns * step) + (loopHeight * 1.10)

        let raw = easeOut * distance
        let mod = raw.truncatingRemainder(dividingBy: loopHeight)
        let y = -mod

        if p >= 0.999 {
            if phase != .final {
                phase = .final
                finalOpacity = 0
                withAnimation(.easeOut(duration: 0.20)) { finalOpacity = 1 }
            }
        }

        return y
    }

    @ViewBuilder
    private func loopStrip(step: CGFloat, offset: CGFloat) -> some View {
        let symbols = base.isEmpty ? SlotSymbol.safeDefaultWindow(rows: max(22, visibleRows * 6)) : base

        VStack(spacing: rowGap) {
            ForEach(Array(symbols.enumerated()), id: \.offset) { _, sym in
                Image(EgyptSymbolMapper.imageName(for: sym))
                    .resizable()
                    .scaledToFit()
                    .frame(width: symbolSize, height: symbolSize)
            }

            ForEach(Array(symbols.enumerated()), id: \.offset) { _, sym in
                Image(EgyptSymbolMapper.imageName(for: sym))
                    .resizable()
                    .scaledToFit()
                    .frame(width: symbolSize, height: symbolSize)
            }
        }
        .offset(y: offset)
        .frame(width: reelWidth, alignment: .top)
    }

    @ViewBuilder
    private func finalStrip() -> some View {
        let fw = finalWindow.isEmpty ? SlotSymbol.safeDefaultWindow(rows: visibleRows) : finalWindow

        VStack(spacing: rowGap) {
            ForEach(Array(fw.enumerated()), id: \.offset) { row, sym in
                Image(EgyptSymbolMapper.imageName(for: sym))
                    .resizable()
                    .scaledToFit()
                    .frame(width: symbolSize, height: symbolSize)
                    .anchorPreference(key: EgyptSymbolBoundsPreferenceKey.self, value: .bounds) { a in
                        [EgyptSymbolCellKey(reel: reelIndex, row: row): a]
                    }
            }
        }
        .frame(width: reelWidth, alignment: .center)
    }
}

private enum EgyptSymbolMapper {
    static func imageName(for symbol: SlotSymbol) -> String {
        switch symbol {
        case .strawberry: return "pyramid"
        case .cherry: return "Eye_of_Horus"
        case .watermelon: return "Sun_disk_of_Ra"
        case .grape: return "pyramid_2"
        case .bell: return "Hand_of_Pharaoh"
        case .three: return "pyramid_2"
        }
    }
}

private struct EgyptSlotGrid {
    let rows: Int
    let col0: [SlotSymbol]
    let col1: [SlotSymbol]
    let col2: [SlotSymbol]

    func symbol(col: Int, row: Int) -> SlotSymbol? {
        guard row >= 0, row < rows else { return nil }
        switch col {
        case 0: return row < col0.count ? col0[row] : nil
        case 1: return row < col1.count ? col1[row] : nil
        case 2: return row < col2.count ? col2[row] : nil
        default: return nil
        }
    }
}

private struct EgyptPayline: Identifiable, Equatable {
    let id: String
    let rowsByReel: [Int]

    static func defaults(forRows rows: Int) -> [EgyptPayline] {
        let safeRows = max(1, rows)
        let top = EgyptPayline(id: "top", rowsByReel: [0, 0, 0])
        let center = EgyptPayline.center(forRows: safeRows)
        let mid2 = EgyptPayline(
            id: "mid2",
            rowsByReel: [min(2, safeRows - 1), min(2, safeRows - 1), min(2, safeRows - 1)]
        )
        let bottom = EgyptPayline(id: "bottom", rowsByReel: [safeRows - 1, safeRows - 1, safeRows - 1])

        let diagDown = EgyptPayline(id: "diagDown", rowsByReel: [0, 1, 2].map { min(max($0, 0), safeRows - 1) })
        let diagUp = EgyptPayline(id: "diagUp", rowsByReel: [2, 1, 0].map { min(max($0, 0), safeRows - 1) })

        return [top, center, mid2, bottom, diagDown, diagUp]
    }

    static func center(forRows rows: Int) -> EgyptPayline {
        let r = max(1, rows)
        let center = min(r - 1, 1)
        return EgyptPayline(id: "center", rowsByReel: [center, center, center])
    }

    func isWin(in grid: EgyptSlotGrid) -> Bool {
        guard rowsByReel.count == 3 else { return false }
        guard
            let a = grid.symbol(col: 0, row: rowsByReel[0]),
            let b = grid.symbol(col: 1, row: rowsByReel[1]),
            let c = grid.symbol(col: 2, row: rowsByReel[2])
        else { return false }
        return a == b && b == c
    }
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b: UInt64
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

        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: 1.0
        )
    }
}
