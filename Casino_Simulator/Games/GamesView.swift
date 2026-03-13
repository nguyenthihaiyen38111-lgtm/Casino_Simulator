// Path: Games/GamesView.swift
//Developer Chuong Nguyen

import SwiftUI
import UIKit

struct GamesView: View {
    let bottomInset: CGFloat
    let onOpenProfile: () -> Void
    let onOpenCasino: (GameCasProfSt.CasinoMode) -> Void

    @EnvironmentObject private var profile: GameCasProfSt

    private enum Assets {
        static let background = "back_lobby"

        static let hot = "hot"
        static let emerald = "castle"
        static let fruit = "fruit"
        static let pharaoh = "pharaoh"
        static let poker = "poker"
        static let fish = "lucky"
    }

    private enum Palette {
        static let redStrokeA = Color(hex: "D64653")
        static let redStrokeB = Color(hex: "870207")
        static let greenStrokeA = Color(hex: "81E456")
        static let greenStrokeB = Color(hex: "04913F")
        static let blueStrokeA = Color(hex: "00A9F8")
        static let blueStrokeB = Color(hex: "00306D")

        static let lockFill = Color.black.opacity(0.48)
        static let lockStroke = Color.white.opacity(0.18)
        static let lockText = Color.white
        static let lockChipFill = Color.black.opacity(0.22)
        static let lockChipStroke = Color.white.opacity(0.10)
    }

    private enum Layout {
        static func isCompact(_ w: CGFloat) -> Bool { w <= 375 }

        struct Metrics {
            let topInset: CGFloat
            let sideInset: CGFloat
            let contentDownShift: CGFloat

            let eventTopGap: CGFloat
            let eventCornerRadius: CGFloat
            let eventStrokeWidth: CGFloat
            let eventHeight: CGFloat

            let gridTopGap: CGFloat
            let gridRowSpacing: CGFloat
            let gridColSpacing: CGFloat

            let cardCornerRadius: CGFloat
            let cardStrokeWidth: CGFloat
            let cardHeightFactor: CGFloat
        }

        static let compact = Metrics(
            topInset: 34,
            sideInset: 22,
            contentDownShift: 10,

            eventTopGap: 16,
            eventCornerRadius: 16,
            eventStrokeWidth: 3,
            eventHeight: 100,

            gridTopGap: 14,
            gridRowSpacing: 12,
            gridColSpacing: 12,

            cardCornerRadius: 14,
            cardStrokeWidth: 3,
            cardHeightFactor: 1.18
        )

        static let regular = Metrics(
            topInset: 32,
            sideInset: 28,
            contentDownShift: 0,

            eventTopGap: 16,
            eventCornerRadius: 18,
            eventStrokeWidth: 3.5,
            eventHeight: 120,

            gridTopGap: 18,
            gridRowSpacing: 16,
            gridColSpacing: 16,

            cardCornerRadius: 16,
            cardStrokeWidth: 3.5,
            cardHeightFactor: 1.25
        )

        static func metrics(forWidth w: CGFloat) -> Metrics {
            isCompact(w) ? compact : regular
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let m = Layout.metrics(forWidth: w)

            let contentWidth = max(0, w - (m.sideInset * 2))
            let cardWidth = floor((contentWidth - (m.gridColSpacing * 2)) / 3)
            let cardHeight = floor(cardWidth * m.cardHeightFactor)

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

                        Button {
                            onOpenCasino(profile.inventoryEventMode)
                        } label: {
                            eventCard(
                                m: m,
                                assetName: profile.inventoryEventAssetName,
                                mode: profile.inventoryEventMode
                            )
                            .frame(height: m.eventHeight)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, m.eventTopGap)
                        .padding(.horizontal, m.sideInset)

                        gamesGrid(m: m, cardWidth: cardWidth, cardHeight: cardHeight)
                            .padding(.top, m.gridTopGap)
                            .padding(.horizontal, m.sideInset)

                        Spacer(minLength: 0)
                            .frame(height: bottomInset)
                    }
                    .padding(.top, m.contentDownShift)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }

    @ViewBuilder
    private func eventCard(m: Layout.Metrics, assetName: String, mode: GameCasProfSt.CasinoMode) -> some View {
        let stroke = eventStroke(for: mode)
        let locked = !profile.isModeUnlocked(mode)

        Image(assetName)
            .resizable()
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: m.eventCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: m.eventCornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: stroke.a, location: 0.0),
                                .init(color: stroke.b, location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: m.eventStrokeWidth
                    )
            )
            .overlay(lockOverlay(isLocked: locked, corner: m.eventCornerRadius))
            .clipped()
            .contentShape(RoundedRectangle(cornerRadius: m.eventCornerRadius, style: .continuous))
    }

    private func eventStroke(for mode: GameCasProfSt.CasinoMode) -> (a: Color, b: Color) {
        switch mode {
        case .emerald:
            return (Palette.greenStrokeA, Palette.greenStrokeB)
        case .fish:
            return (Palette.blueStrokeA, Palette.blueStrokeB)
        default:
            return (Palette.redStrokeA, Palette.redStrokeB)
        }
    }

    @ViewBuilder
    private func gamesGrid(m: Layout.Metrics, cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        VStack(spacing: m.gridRowSpacing) {
            HStack(spacing: m.gridColSpacing) {
                gameCard(m: m, mode: .hot, imageName: Assets.hot, strokeA: Palette.redStrokeA, strokeB: Palette.redStrokeB, width: cardWidth, height: cardHeight)
                gameCard(m: m, mode: .emerald, imageName: Assets.emerald, strokeA: Palette.greenStrokeA, strokeB: Palette.greenStrokeB, width: cardWidth, height: cardHeight)
                gameCard(m: m, mode: .pharaoh, imageName: Assets.pharaoh, strokeA: Palette.redStrokeA, strokeB: Palette.redStrokeB, width: cardWidth, height: cardHeight)
            }

            HStack(spacing: m.gridColSpacing) {
                gameCard(m: m, mode: .fruit, imageName: Assets.fruit, strokeA: Palette.redStrokeA, strokeB: Palette.redStrokeB, width: cardWidth, height: cardHeight)
                gameCard(m: m, mode: .poker, imageName: Assets.poker, strokeA: Palette.redStrokeA, strokeB: Palette.redStrokeB, width: cardWidth, height: cardHeight)
                gameCard(m: m, mode: .fish, imageName: Assets.fish, strokeA: Palette.blueStrokeA, strokeB: Palette.blueStrokeB, width: cardWidth, height: cardHeight)
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
        height: CGFloat
    ) -> some View {
        let locked = !profile.isModeUnlocked(mode)

        Button {
            onOpenCasino(mode)
        } label: {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: m.cardCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: m.cardCornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: strokeA, location: 0.0),
                                    .init(color: strokeB, location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: m.cardStrokeWidth
                        )
                )
                .overlay(lockOverlay(isLocked: locked, corner: m.cardCornerRadius))
                .clipped()
                .contentShape(RoundedRectangle(cornerRadius: m.cardCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
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
