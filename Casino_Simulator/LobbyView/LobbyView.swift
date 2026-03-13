// Path: lobbyView/LobbyView.swift
//Developer Chuong Nguyen

import SwiftUI
import UIKit

struct LobbyView: View {
    let bottomInset: CGFloat
    let onOpenProfile: () -> Void
    let onOpenCasino: (GameCasProfSt.CasinoMode) -> Void

    @EnvironmentObject private var profile: GameCasProfSt

    private enum Assets {
        static let background = "back_lobby"

        static let bonus = "bonus"
        static let claimNow = "claim_now"

        static let hot = "hot"
        static let emerald = "castle"
        static let fruit = "fruit"

        static let pharaoh = "pharaoh"
        static let poker = "poker"
        static let fish = "lucky"
    }

    private enum Palette {
        static let bonusStrokeA = Color(hex: "7B7B42")
        static let bonusStrokeB = Color(hex: "F2262F")
        static let bonusFillA = Color(hex: "1A5018")
        static let bonusFillB = Color(hex: "090C05")
        static let bonusBokeh = Color(hex: "E43031")
        static let bonusTitle = Color.white

        static let spinTextA = Color(hex: "FDF4B4")
        static let spinTextB = Color(hex: "FBB339")
        static let spinStrokeA = Color(hex: "FFA598")
        static let spinStrokeB = Color(hex: "921A1E")
        static let spinFillA = Color(hex: "FC0502")
        static let spinFillB = Color(hex: "530101")

        static let gameCardRedA = Color(hex: "D64653")
        static let gameCardRedB = Color(hex: "870207")
        static let gameCardGreenA = Color(hex: "81E456")
        static let gameCardGreenB = Color(hex: "04913F")

        static let timerFill = Color.black.opacity(0.28)
        static let timerStroke = Color.white.opacity(0.16)
        static let timerText = Color.white

        static let lockFill = Color.black.opacity(0.48)
        static let lockText = Color.white
        static let lockChipFill = Color.black.opacity(0.22)
        static let lockChipStroke = Color.white.opacity(0.10)
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
            let topInset: CGFloat
            let sideInset: CGFloat

            let dailyTopGap: CGFloat
            let dailyCardsSpacing: CGFloat
            let dailyCardMaxSide: CGFloat
            let dailyCornerRadius: CGFloat
            let dailyStroke: CGFloat

            let dailyTitleFont: CGFloat
            let dailyTitlePadTop: CGFloat
            let dailyTitlePadLeading: CGFloat

            let dailyBonusWidthFactor: CGFloat
            let dailyBonusTopPad: CGFloat
            let dailyBonusYFactor: CGFloat

            let dailyClaimHeight: CGFloat
            let dailyClaimBottomPad: CGFloat
            let dailyTimerHeight: CGFloat
            let dailyTimerHPad: CGFloat
            let dailyTimerText: CGFloat
            let dailyTimerCorner: CGFloat

            let dailyBokehBlur: CGFloat

            let spinTopGap: CGFloat
            let spinHeight: CGFloat
            let spinCornerRadius: CGFloat
            let spinStrokeWidth: CGFloat
            let spinInnerInset: CGFloat
            let spinTextSize: CGFloat
            let spinTextTracking: CGFloat

            let gamesTopGap: CGFloat
            let gamesRowSpacing: CGFloat
            let gamesCardCornerRadius: CGFloat
            let gamesCardStrokeWidth: CGFloat
            let gamesCardHeightFactor: CGFloat

            let extraGridTopGap: CGFloat
            let extraGridRowSpacing: CGFloat
            let extraGridColSpacing: CGFloat
            let extraCardCornerRadius: CGFloat
            let extraCardStrokeWidth: CGFloat
            let extraCardHeightFactor: CGFloat

            let compactScale: CGFloat
            let compactDownShift: CGFloat
        }

        static let compact = Metrics(
            topInset: 24,
            sideInset: 22,

            dailyTopGap: 16,
            dailyCardsSpacing: 14,
            dailyCardMaxSide: 160,
            dailyCornerRadius: 16,
            dailyStroke: 3,

            dailyTitleFont: 17,
            dailyTitlePadTop: 12,
            dailyTitlePadLeading: 12,

            dailyBonusWidthFactor: 0.88,
            dailyBonusTopPad: 20,
            dailyBonusYFactor: 0.39,

            dailyClaimHeight: 23,
            dailyClaimBottomPad: 26,
            dailyTimerHeight: 24,
            dailyTimerHPad: 10,
            dailyTimerText: 11,
            dailyTimerCorner: 10,

            dailyBokehBlur: 40,

            spinTopGap: 16,
            spinHeight: 80,
            spinCornerRadius: 42,
            spinStrokeWidth: 4,
            spinInnerInset: 6,
            spinTextSize: 38,
            spinTextTracking: 0,

            gamesTopGap: 16,
            gamesRowSpacing: 12,
            gamesCardCornerRadius: 14,
            gamesCardStrokeWidth: 3,
            gamesCardHeightFactor: 1.48,

            extraGridTopGap: 12,
            extraGridRowSpacing: 12,
            extraGridColSpacing: 12,
            extraCardCornerRadius: 14,
            extraCardStrokeWidth: 3,
            extraCardHeightFactor: 1.12,

            compactScale: 0.93,
            compactDownShift: 8
        )

        static let regular = Metrics(
            topInset: 32,
            sideInset: 28,

            dailyTopGap: 22,
            dailyCardsSpacing: 18,
            dailyCardMaxSide: 188,
            dailyCornerRadius: 18,
            dailyStroke: 3,

            dailyTitleFont: 20,
            dailyTitlePadTop: 14,
            dailyTitlePadLeading: 14,

            dailyBonusWidthFactor: 0.92,
            dailyBonusTopPad: 40,
            dailyBonusYFactor: 0.40,

            dailyClaimHeight: 28,
            dailyClaimBottomPad: 14,
            dailyTimerHeight: 28,
            dailyTimerHPad: 12,
            dailyTimerText: 13,
            dailyTimerCorner: 12,

            dailyBokehBlur: 44,

            spinTopGap: 22,
            spinHeight: 100,
            spinCornerRadius: 52,
            spinStrokeWidth: 5,
            spinInnerInset: 7,
            spinTextSize: 48,
            spinTextTracking: 0,

            gamesTopGap: 22,
            gamesRowSpacing: 16,
            gamesCardCornerRadius: 16,
            gamesCardStrokeWidth: 3.5,
            gamesCardHeightFactor: 1.62,

            extraGridTopGap: 16,
            extraGridRowSpacing: 16,
            extraGridColSpacing: 16,
            extraCardCornerRadius: 16,
            extraCardStrokeWidth: 3.5,
            extraCardHeightFactor: 1.25,

            compactScale: 1.0,
            compactDownShift: 0
        )

        static func metrics(forWidth w: CGFloat) -> Metrics {
            isCompact(w) ? compact : regular
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let m = Layout.metrics(forWidth: w)
            let isCompact = Layout.isCompact(w)

            let availableRowWidth = max(0, w - (m.sideInset * 2))
            let maxDailySideThatFits = max(0, (availableRowWidth - m.dailyCardsSpacing) / 2)
            let dailySide = floor(min(m.dailyCardMaxSide, maxDailySideThatFits))

            let maxGamesCardWidthThatFits = max(0, (availableRowWidth - (m.gamesRowSpacing * 2)) / 3)
            let gamesCardWidth = floor(maxGamesCardWidthThatFits)
            let gamesCardHeight = floor(gamesCardWidth * m.gamesCardHeightFactor)

            let contentWidth = max(0, w - (m.sideInset * 2))
            let extraCardWidth = floor((contentWidth - (m.extraGridColSpacing * 2)) / 3)
            let extraCardHeight = floor(extraCardWidth * m.extraCardHeightFactor)

            ZStack {
                Image(Assets.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        TopHUDView(onOpenProfile: onOpenProfile)
                            .padding(.top, m.topInset)
                            .padding(.horizontal, m.sideInset)

                        HStack(spacing: m.dailyCardsSpacing) {
                            dailyBonusBlock(m: m, side: dailySide)
                            twoHourBonusBlock(m: m, side: dailySide)
                        }
                        .padding(.top, m.dailyTopGap)
                        .padding(.horizontal, m.sideInset)
                        .frame(maxWidth: .infinity, alignment: .center)

                        spinWinBanner(m: m)
                            .padding(.top, m.spinTopGap)
                            .padding(.horizontal, m.sideInset)
                            .onTapGesture {
                                onOpenCasino(.hot)
                            }

                        gamesRow(
                            m: m,
                            cardWidth: gamesCardWidth,
                            cardHeight: gamesCardHeight
                        )
                        .padding(.top, m.gamesTopGap)
                        .padding(.horizontal, m.sideInset)

                        extraGamesGrid(
                            m: m,
                            cardWidth: extraCardWidth,
                            cardHeight: extraCardHeight
                        )
                        .padding(.top, m.extraGridTopGap)
                        .padding(.horizontal, m.sideInset)

                        Spacer(minLength: 0)
                            .frame(height: bottomInset)
                    }
                    .scaleEffect(isCompact ? m.compactScale : 1.0, anchor: .top)
                    .padding(.top, isCompact ? m.compactDownShift : 0)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
        }
    }

    @ViewBuilder
    private func dailyBonusBlock(m: Layout.Metrics, side: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            dailyCardChrome(m: m)

            Text("Daily Bonus")
                .font(Typography.font(size: m.dailyTitleFont))
                .foregroundColor(Palette.bonusTitle)
                .padding(.top, m.dailyTitlePadTop)
                .padding(.leading, m.dailyTitlePadLeading)

            GeometryReader { gp in
                let cw = gp.size.width
                let ch = gp.size.height

                Image(Assets.bonus)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cw * m.dailyBonusWidthFactor)
                    .position(
                        x: cw * 0.50,
                        y: (ch * m.dailyBonusYFactor) + m.dailyBonusTopPad
                    )

                Group {
                    if profile.canClaimDailyBonus {
                        Button {
                            profile.claimDailyBonus()
                        } label: {
                            Image(Assets.claimNow)
                                .resizable()
                                .scaledToFit()
                                .frame(height: m.dailyClaimHeight)
                        }
                        .buttonStyle(.plain)
                    } else {
                        TimelineView(.periodic(from: .now, by: 1)) { _ in
                            Text(profile.dailyBonusRemainingText)
                                .font(Typography.font(size: m.dailyTimerText))
                                .foregroundColor(Palette.timerText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .padding(.horizontal, m.dailyTimerHPad)
                                .frame(height: m.dailyTimerHeight)
                                .background(
                                    RoundedRectangle(cornerRadius: m.dailyTimerCorner, style: .continuous)
                                        .fill(Palette.timerFill)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: m.dailyTimerCorner, style: .continuous)
                                        .stroke(Palette.timerStroke, lineWidth: 1)
                                )
                        }
                    }
                }
                .position(
                    x: cw * 0.50,
                    y: ch - m.dailyClaimBottomPad - (m.dailyClaimHeight * 0.50)
                )
            }
        }
        .frame(width: side, height: side)
    }

    @ViewBuilder
    private func twoHourBonusBlock(m: Layout.Metrics, side: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            dailyCardChrome(m: m)

            Text("Quick Bonus")
                .font(Typography.font(size: m.dailyTitleFont))
                .foregroundColor(Palette.bonusTitle)
                .padding(.top, m.dailyTitlePadTop)
                .padding(.leading, m.dailyTitlePadLeading)

            GeometryReader { gp in
                let cw = gp.size.width
                let ch = gp.size.height

                Image(Assets.bonus)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cw * m.dailyBonusWidthFactor)
                    .position(
                        x: cw * 0.50,
                        y: (ch * m.dailyBonusYFactor) + m.dailyBonusTopPad
                    )

                Group {
                    if profile.canClaimTwoHourBonus {
                        Button {
                            profile.claimTwoHourBonus()
                        } label: {
                            Image(Assets.claimNow)
                                .resizable()
                                .scaledToFit()
                                .frame(height: m.dailyClaimHeight)
                        }
                        .buttonStyle(.plain)
                    } else {
                        TimelineView(.periodic(from: .now, by: 1)) { _ in
                            Text(profile.twoHourBonusRemainingText)
                                .font(Typography.font(size: m.dailyTimerText))
                                .foregroundColor(Palette.timerText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .padding(.horizontal, m.dailyTimerHPad)
                                .frame(height: m.dailyTimerHeight)
                                .background(
                                    RoundedRectangle(cornerRadius: m.dailyTimerCorner, style: .continuous)
                                        .fill(Palette.timerFill)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: m.dailyTimerCorner, style: .continuous)
                                        .stroke(Palette.timerStroke, lineWidth: 1)
                                )
                        }
                    }
                }
                .position(
                    x: cw * 0.50,
                    y: ch - m.dailyClaimBottomPad - (m.dailyClaimHeight * 0.50)
                )
            }
        }
        .frame(width: side, height: side)
    }

    @ViewBuilder
    private func dailyCardChrome(m: Layout.Metrics) -> some View {
        RoundedRectangle(cornerRadius: m.dailyCornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Palette.bonusFillA, location: 0.05),
                        .init(color: Palette.bonusFillB, location: 0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

        dailyBokehLayer(m: m)
            .clipShape(RoundedRectangle(cornerRadius: m.dailyCornerRadius, style: .continuous))

        RoundedRectangle(cornerRadius: m.dailyCornerRadius, style: .continuous)
            .stroke(
                LinearGradient(
                    stops: [
                        .init(color: Palette.bonusStrokeA, location: 0.0),
                        .init(color: Palette.bonusStrokeB, location: 1.0)
                    ],
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                ),
                lineWidth: m.dailyStroke
            )
    }

    @ViewBuilder
    private func dailyBokehLayer(m: Layout.Metrics) -> some View {
        GeometryReader { gp in
            let w = gp.size.width
            let h = gp.size.height
            ZStack {
                Circle()
                    .fill(Palette.bonusBokeh.opacity(0.38))
                    .frame(width: w * 0.56, height: w * 0.56)
                    .position(x: w * 0.18, y: h * 0.18)
                    .blur(radius: m.dailyBokehBlur)

                Circle()
                    .fill(Palette.bonusBokeh.opacity(0.34))
                    .frame(width: w * 0.46, height: w * 0.46)
                    .position(x: w * 0.82, y: h * 0.20)
                    .blur(radius: m.dailyBokehBlur)

                Circle()
                    .fill(Palette.bonusBokeh.opacity(0.32))
                    .frame(width: w * 0.52, height: w * 0.52)
                    .position(x: w * 0.74, y: h * 0.76)
                    .blur(radius: m.dailyBokehBlur)

                Circle()
                    .fill(Palette.bonusBokeh.opacity(0.30))
                    .frame(width: w * 0.44, height: w * 0.44)
                    .position(x: w * 0.22, y: h * 0.74)
                    .blur(radius: m.dailyBokehBlur)

                Circle()
                    .fill(Palette.bonusBokeh.opacity(0.26))
                    .frame(width: w * 0.34, height: w * 0.34)
                    .position(x: w * 0.52, y: h * 0.46)
                    .blur(radius: m.dailyBokehBlur)

                Circle()
                    .fill(Palette.bonusBokeh.opacity(0.24))
                    .frame(width: w * 0.26, height: w * 0.26)
                    .position(x: w * 0.10, y: h * 0.90)
                    .blur(radius: m.dailyBokehBlur)

                Circle()
                    .fill(Palette.bonusBokeh.opacity(0.24))
                    .frame(width: w * 0.26, height: w * 0.26)
                    .position(x: w * 0.92, y: h * 0.90)
                    .blur(radius: m.dailyBokehBlur)
            }
        }
    }

    @ViewBuilder
    private func spinWinBanner(m: Layout.Metrics) -> some View {
        let outer = RoundedRectangle(cornerRadius: m.spinCornerRadius, style: .continuous)
        let innerCorner = max(0, m.spinCornerRadius - m.spinInnerInset)

        ZStack {
            outer
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: Palette.spinStrokeA, location: 0.0),
                            .init(color: Palette.spinStrokeB, location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: m.spinStrokeWidth
                )

            RoundedRectangle(cornerRadius: innerCorner, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Palette.spinFillA, location: 0.0),
                            .init(color: Palette.spinFillB, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(m.spinInnerInset)

            LinearGradient(
                stops: [
                    .init(color: Palette.spinTextA, location: 0.36),
                    .init(color: Palette.spinTextB, location: 1.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .mask(
                Text("Spin & Prizes !")
                    .font(Typography.font(size: m.spinTextSize))
                    .tracking(m.spinTextTracking)
            )
        }
        .frame(height: m.spinHeight)
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Spin and win")
    }

    @ViewBuilder
    private func gamesRow(m: Layout.Metrics, cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        HStack(spacing: m.gamesRowSpacing) {
            gameCard(
                m: m,
                mode: .hot,
                imageName: Assets.hot,
                strokeA: Palette.gameCardRedA,
                strokeB: Palette.gameCardRedB,
                width: cardWidth,
                height: cardHeight,
                onTap: { onOpenCasino(.hot) }
            )

            gameCard(
                m: m,
                mode: .emerald,
                imageName: Assets.emerald,
                strokeA: Palette.gameCardGreenA,
                strokeB: Palette.gameCardGreenB,
                width: cardWidth,
                height: cardHeight,
                onTap: { onOpenCasino(.emerald) }
            )

            gameCard(
                m: m,
                mode: .fruit,
                imageName: Assets.fruit,
                strokeA: Palette.gameCardRedA,
                strokeB: Palette.gameCardRedB,
                width: cardWidth,
                height: cardHeight,
                onTap: { onOpenCasino(.fruit) }
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func extraGamesGrid(m: Layout.Metrics, cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        VStack(spacing: m.extraGridRowSpacing) {
            HStack(spacing: m.extraGridColSpacing) {
                extraCard(
                    m: m,
                    mode: .pharaoh,
                    imageName: Assets.pharaoh,
                    strokeA: Palette.gameCardRedA,
                    strokeB: Palette.gameCardRedB,
                    width: cardWidth,
                    height: cardHeight,
                    onTap: { onOpenCasino(.pharaoh) }
                )

                extraCard(
                    m: m,
                    mode: .poker,
                    imageName: Assets.poker,
                    strokeA: Palette.gameCardRedA,
                    strokeB: Palette.gameCardRedB,
                    width: cardWidth,
                    height: cardHeight,
                    onTap: { onOpenCasino(.poker) }
                )

                extraCard(
                    m: m,
                    mode: .fish,
                    imageName: Assets.fish,
                    strokeA: Palette.gameCardRedA,
                    strokeB: Palette.gameCardRedB,
                    width: cardWidth,
                    height: cardHeight,
                    onTap: { onOpenCasino(.fish) }
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func gameCard(
        m: Layout.Metrics,
        mode: GameCasProfSt.CasinoMode,
        imageName: String,
        strokeA: Color,
        strokeB: Color,
        width: CGFloat,
        height: CGFloat,
        onTap: @escaping () -> Void
    ) -> some View {
        let locked = !profile.isModeUnlocked(mode)

        Button(action: onTap) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: m.gamesCardCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: m.gamesCardCornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: strokeA, location: 0.0),
                                    .init(color: strokeB, location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: m.gamesCardStrokeWidth
                        )
                )
                .overlay(lockOverlay(isLocked: locked, corner: m.gamesCardCornerRadius))
                .clipped()
                .contentShape(RoundedRectangle(cornerRadius: m.gamesCardCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Game")
    }

    @ViewBuilder
    private func extraCard(
        m: Layout.Metrics,
        mode: GameCasProfSt.CasinoMode,
        imageName: String,
        strokeA: Color,
        strokeB: Color,
        width: CGFloat,
        height: CGFloat,
        onTap: @escaping () -> Void
    ) -> some View {
        let locked = !profile.isModeUnlocked(mode)

        Button(action: onTap) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: m.extraCardCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: m.extraCardCornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: strokeA, location: 0.0),
                                    .init(color: strokeB, location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: m.extraCardStrokeWidth
                        )
                )
                .overlay(lockOverlay(isLocked: locked, corner: m.extraCardCornerRadius))
                .clipped()
                .contentShape(RoundedRectangle(cornerRadius: m.extraCardCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Game")
    }

    @ViewBuilder
    private func lockOverlay(isLocked: Bool, corner: CGFloat) -> some View {
        if isLocked {
            ZStack {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(Palette.lockFill)

                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(Palette.lockText)

                    Text("Locked")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(Palette.lockText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Palette.lockChipFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Palette.lockChipStroke, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
}
