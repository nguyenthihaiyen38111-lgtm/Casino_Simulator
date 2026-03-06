// Path: Achievements/AchievementsView.swift

import SwiftUI
import UIKit

struct AchievementsView: View {
    struct AchievementItem: Identifiable, Equatable {
        let id: String
        let icon: String
        let title: String
        let subtitle: String
        let current: Int
        let target: Int
        let rewardCoins: Int
        let isClaimed: Bool
    }

    let bottomInset: CGFloat

    @EnvironmentObject private var profile: GameCasProfSt

    private enum Assets {
        static let background = "back_lobby"
        static let trophy = "kubok"
        static let coin = "money"
        static let claim = "claim"
    }

    private enum Palette {
        static let title = Color(hex: "FDF2B7")
        static let completed = Color(hex: "C29FA0")

        static let progressStroke = Color(hex: "864325")
        static let progressTrack = Color(hex: "140100")
        static let progressFillA = Color(hex: "C1E78C")
        static let progressFillB = Color(hex: "048601")

        static let cardStrokeA = Color(hex: "E92933")
        static let cardStrokeB = Color(hex: "B51B2D")
        static let cardFillA = Color(hex: "5D0204")
        static let cardFillB = Color(hex: "510104")

        static let primaryText = Color(hex: "FDF2B7")
        static let secondaryText = Color(hex: "E8C8C2")
        static let disabled = Color.white.opacity(0.45)
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

            let trophySize: CGFloat
            let titleSize: CGFloat

            let headerGap: CGFloat
            let barTopGap: CGFloat
            let barHeight: CGFloat
            let barCornerRadius: CGFloat
            let barStrokeWidth: CGFloat
            let barInnerInset: CGFloat
            let completedTopGap: CGFloat
            let completedSize: CGFloat

            let listTopGap: CGFloat
            let listSpacing: CGFloat
            let cardHeight: CGFloat
            let cardCornerRadius: CGFloat
            let cardStrokeWidth: CGFloat
            let cardInnerPadH: CGFloat

            let iconSize: CGFloat
            let iconLeading: CGFloat

            let titleCardSize: CGFloat
            let subtitleCardSize: CGFloat
            let textBlockTopPad: CGFloat
            let textBlockLeadingFromIcon: CGFloat
            let subtitleTopGap: CGFloat

            let innerProgressTopGap: CGFloat
            let innerProgressHeight: CGFloat
            let innerProgressCornerRadius: CGFloat
            let innerProgressStrokeWidth: CGFloat
            let innerProgressInnerInset: CGFloat

            let progressLabelSize: CGFloat
            let progressLabelPadLeading: CGFloat
            let progressLabelPadTop: CGFloat

            let rightBlockWidth: CGFloat
            let claimHeight: CGFloat
            let rightCoinSize: CGFloat
            let rewardSize: CGFloat
            let rightGap: CGFloat
        }

        static let compact = Metrics(
            sideInset: 22,
            topInset: 26,

            trophySize: 72,
            titleSize: 40,

            headerGap: 6,
            barTopGap: 10,
            barHeight: 16,
            barCornerRadius: 10,
            barStrokeWidth: 2,
            barInnerInset: 2,
            completedTopGap: 6,
            completedSize: 16,

            listTopGap: 12,
            listSpacing: 14,
            cardHeight: 82,
            cardCornerRadius: 16,
            cardStrokeWidth: 3,
            cardInnerPadH: 12,

            iconSize: 48,
            iconLeading: 12,

            titleCardSize: 20,
            subtitleCardSize: 14,
            textBlockTopPad: 8,
            textBlockLeadingFromIcon: 12,
            subtitleTopGap: 2,

            innerProgressTopGap: 6,
            innerProgressHeight: 16,
            innerProgressCornerRadius: 9,
            innerProgressStrokeWidth: 1.8,
            innerProgressInnerInset: 1.6,

            progressLabelSize: 13,
            progressLabelPadLeading: 9,
            progressLabelPadTop: 1,

            rightBlockWidth: 110,
            claimHeight: 26,
            rightCoinSize: 20,
            rewardSize: 24,
            rightGap: 8
        )

        static let regular = Metrics(
            sideInset: 28,
            topInset: 34,

            trophySize: 84,
            titleSize: 46,

            headerGap: 8,
            barTopGap: 12,
            barHeight: 18,
            barCornerRadius: 11,
            barStrokeWidth: 2.2,
            barInnerInset: 2.2,
            completedTopGap: 8,
            completedSize: 18,

            listTopGap: 14,
            listSpacing: 16,
            cardHeight: 94,
            cardCornerRadius: 18,
            cardStrokeWidth: 3.5,
            cardInnerPadH: 14,

            iconSize: 56,
            iconLeading: 14,

            titleCardSize: 22,
            subtitleCardSize: 15,
            textBlockTopPad: 10,
            textBlockLeadingFromIcon: 14,
            subtitleTopGap: 3,

            innerProgressTopGap: 8,
            innerProgressHeight: 18,
            innerProgressCornerRadius: 10,
            innerProgressStrokeWidth: 2.0,
            innerProgressInnerInset: 1.8,

            progressLabelSize: 14,
            progressLabelPadLeading: 10,
            progressLabelPadTop: 1,

            rightBlockWidth: 120,
            claimHeight: 28,
            rightCoinSize: 22,
            rewardSize: 26,
            rightGap: 9
        )

        static func metrics(forWidth w: CGFloat) -> Metrics {
            isCompact(w) ? compact : regular
        }
    }

    private var items: [AchievementItem] {
        AchievementDefinitions.all.map { def in
            let current = profile.achievementProgressValue(for: def.id)
            return AchievementItem(
                id: def.id,
                icon: def.icon,
                title: def.title,
                subtitle: def.subtitle,
                current: current,
                target: def.target,
                rewardCoins: def.rewardCoins,
                isClaimed: profile.isClaimed(.achievement, id: def.id)
            )
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let m = Layout.metrics(forWidth: w)

            ZStack {
                Image(Assets.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        header(m: m)
                            .padding(.top, m.topInset)
                            .padding(.horizontal, m.sideInset)

                        achievementsList(m: m)
                            .padding(.top, m.listTopGap)
                            .padding(.horizontal, m.sideInset)
                            .padding(.bottom, bottomInset)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func header(m: Layout.Metrics) -> some View {
        let total = max(1, items.count)
        let completedCount = items.filter { $0.current >= $0.target }.count
        let progress = CGFloat(completedCount) / CGFloat(total)

        VStack(spacing: 0) {
            Image(Assets.trophy)
                .resizable()
                .scaledToFit()
                .frame(width: m.trophySize, height: m.trophySize)
                .padding(.bottom, m.headerGap)

            Text("Achievements")
                .font(Typography.font(size: m.titleSize))
                .foregroundColor(Palette.title)
                .minimumScaleFactor(0.85)
                .lineLimit(1)

            progressBar(m: m, progress: progress)
                .padding(.top, m.barTopGap)

            Text("\(completedCount)/\(total) Completed")
                .font(Typography.font(size: m.completedSize))
                .foregroundColor(Palette.completed)
                .padding(.top, m.completedTopGap)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func progressBar(m: Layout.Metrics, progress: CGFloat) -> some View {
        let clamped = min(max(progress, 0), 1)

        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: m.barCornerRadius, style: .continuous)
                .fill(Palette.progressTrack)

            RoundedRectangle(cornerRadius: m.barCornerRadius, style: .continuous)
                .stroke(Palette.progressStroke, lineWidth: m.barStrokeWidth)

            GeometryReader { gp in
                let width = gp.size.width
                let fillW = max(0, floor(width * clamped))

                RoundedRectangle(cornerRadius: max(0, m.barCornerRadius - m.barInnerInset), style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Palette.progressFillA, location: 0.0),
                                .init(color: Palette.progressFillB, location: 0.60)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fillW)
                    .padding(m.barInnerInset)
                    .animation(.easeInOut(duration: 0.35), value: fillW)
            }
            .clipShape(RoundedRectangle(cornerRadius: m.barCornerRadius, style: .continuous))
        }
        .frame(height: m.barHeight)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func achievementsList(m: Layout.Metrics) -> some View {
        VStack(spacing: m.listSpacing) {
            ForEach(items) { item in
                achievementCard(m: m, item: item)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func achievementCard(m: Layout.Metrics, item: AchievementItem) -> some View {
        let outer = RoundedRectangle(cornerRadius: m.cardCornerRadius, style: .continuous)
        let progress = CGFloat(item.current) / CGFloat(max(1, item.target))
        let progressLabel = "\(min(item.current, item.target))/\(item.target)"
        let isComplete = item.current >= item.target
        let claimEnabled = isComplete && !item.isClaimed

        ZStack {
            outer
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Palette.cardFillA, location: 0.0),
                            .init(color: Palette.cardFillB, location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            outer
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: Palette.cardStrokeA, location: 0.0),
                            .init(color: Palette.cardStrokeB, location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: m.cardStrokeWidth
                )

            HStack(spacing: 0) {
                Image(item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: m.iconSize, height: m.iconSize)
                    .padding(.leading, m.iconLeading)

                VStack(alignment: .leading, spacing: 0) {
                    Text(item.title)
                        .font(Typography.font(size: m.titleCardSize))
                        .foregroundColor(Palette.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.88)

                    Text(item.subtitle)
                        .font(Typography.font(size: m.subtitleCardSize))
                        .foregroundColor(Palette.secondaryText)
                        .padding(.top, m.subtitleTopGap)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    ZStack(alignment: .leading) {
                        innerProgressBar(m: m, progress: progress)

                        Text(progressLabel)
                            .font(Typography.font(size: m.progressLabelSize))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.leading, m.progressLabelPadLeading)
                            .padding(.top, m.progressLabelPadTop)
                    }
                    .padding(.top, m.innerProgressTopGap)
                }
                .padding(.top, m.textBlockTopPad)
                .padding(.leading, m.textBlockLeadingFromIcon)
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 0) {
                    Button {
                        profile.claimAchievement(id: item.id)
                    } label: {
                        Image(Assets.claim)
                            .resizable()
                            .scaledToFit()
                            .frame(height: m.claimHeight)
                            .opacity(claimEnabled ? 1.0 : 0.55)
                    }
                    .buttonStyle(.plain)
                    .disabled(!claimEnabled)

                    HStack(spacing: 10) {
                        Image(Assets.coin)
                            .resizable()
                            .scaledToFit()
                            .frame(width: m.rightCoinSize, height: m.rightCoinSize)

                        Text("\(item.rewardCoins)")
                            .font(Typography.font(size: m.rewardSize))
                            .foregroundColor(Palette.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .padding(.top, m.rightGap)

                    if item.isClaimed {
                        Text("Claimed")
                            .font(Typography.font(size: 12))
                            .foregroundColor(Palette.disabled)
                            .padding(.top, 4)
                    }
                }
                .frame(width: m.rightBlockWidth)
                .padding(.trailing, m.cardInnerPadH)
            }
        }
        .frame(height: m.cardHeight)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func innerProgressBar(m: Layout.Metrics, progress: CGFloat) -> some View {
        let clamped = min(max(progress, 0), 1)
        let corner = m.innerProgressCornerRadius

        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Palette.progressTrack)

            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(Palette.progressStroke, lineWidth: m.innerProgressStrokeWidth)

            GeometryReader { gp in
                let width = gp.size.width
                let fillW = max(0, floor(width * clamped))

                RoundedRectangle(cornerRadius: max(0, corner - m.innerProgressInnerInset), style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Palette.progressFillA, location: 0.0),
                                .init(color: Palette.progressFillB, location: 0.60)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fillW)
                    .padding(m.innerProgressInnerInset)
                    .animation(.easeInOut(duration: 0.35), value: fillW)
            }
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        }
        .frame(height: m.innerProgressHeight)
        .frame(maxWidth: .infinity)
    }
}
