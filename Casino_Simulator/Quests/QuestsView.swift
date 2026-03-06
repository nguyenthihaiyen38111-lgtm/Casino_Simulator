// Path: Quests/QuestsView.swift

import SwiftUI
import UIKit

struct QuestsView: View {
    struct QuestItem: Identifiable, Equatable {
        let id: String
        let title: String
        let current: Int
        let target: Int
        let rewardCoins: Int
        let isClaimed: Bool
    }

    let bottomInset: CGFloat

    @EnvironmentObject private var profile: GameCasProfSt

    private enum Assets {
        static let background = "back_lobby"
        static let header = "ques"
        static let icon = "icon_ques"
        static let coin = "money"
        static let claim = "claim"
    }

    private enum Palette {
        static let progressStroke = Color(hex: "864325")
        static let progressTrack = Color(hex: "6F2A1A")
        static let progressFillA = Color(hex: "C1E78C")
        static let progressFillB = Color(hex: "048601")
        static let progressLabel = Color(hex: "A8CD71")

        static let cardStrokeA = Color(hex: "E92933")
        static let cardStrokeB = Color(hex: "B51B2D")
        static let cardFillA = Color(hex: "5D0204")
        static let cardFillB = Color(hex: "510104")

        static let primaryText = Color(hex: "FDF2B7")
        static let rewardText = Color(hex: "E8C8C2")
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

            let headerHeight: CGFloat
            let headerMaxWidthFactor: CGFloat
            let headerTopGap: CGFloat

            let listTopGap: CGFloat
            let listSpacing: CGFloat

            let cardHeight: CGFloat
            let cardCornerRadius: CGFloat
            let cardStrokeWidth: CGFloat

            let iconSize: CGFloat
            let iconLeading: CGFloat

            let titleSize: CGFloat
            let titleTopPad: CGFloat
            let titleLeadingFromIcon: CGFloat

            let progressTopGap: CGFloat
            let progressHeight: CGFloat
            let progressCornerRadius: CGFloat
            let progressStrokeWidth: CGFloat
            let progressInnerInset: CGFloat

            let progressLabelSize: CGFloat
            let progressLabelTrailing: CGFloat

            let rewardTopGap: CGFloat
            let rewardCoinSize: CGFloat
            let rewardSize: CGFloat

            let claimWidth: CGFloat
            let claimHeight: CGFloat
            let claimTrailing: CGFloat

            let contentLiftY: CGFloat
        }

        static let compact = Metrics(
            sideInset: 22,
            topInset: 22,

            headerHeight: 140,
            headerMaxWidthFactor: 0.98,
            headerTopGap: 4,

            listTopGap: 12,
            listSpacing: 14,

            cardHeight: 74,
            cardCornerRadius: 16,
            cardStrokeWidth: 3,

            iconSize: 40,
            iconLeading: 12,

            titleSize: 18,
            titleTopPad: 6,
            titleLeadingFromIcon: 12,

            progressTopGap: 5,
            progressHeight: 12,
            progressCornerRadius: 8,
            progressStrokeWidth: 1.6,
            progressInnerInset: 2,

            progressLabelSize: 12,
            progressLabelTrailing: 8,

            rewardTopGap: 5,
            rewardCoinSize: 13,
            rewardSize: 14,

            claimWidth: 108,
            claimHeight: 26,
            claimTrailing: 14,

            contentLiftY: -3
        )

        static let regular = Metrics(
            sideInset: 28,
            topInset: 28,

            headerHeight: 150,
            headerMaxWidthFactor: 0.98,
            headerTopGap: 6,

            listTopGap: 14,
            listSpacing: 16,

            cardHeight: 84,
            cardCornerRadius: 18,
            cardStrokeWidth: 3.5,

            iconSize: 46,
            iconLeading: 14,

            titleSize: 20,
            titleTopPad: 8,
            titleLeadingFromIcon: 14,

            progressTopGap: 6,
            progressHeight: 14,
            progressCornerRadius: 9,
            progressStrokeWidth: 1.8,
            progressInnerInset: 2,

            progressLabelSize: 13,
            progressLabelTrailing: 10,

            rewardTopGap: 6,
            rewardCoinSize: 15,
            rewardSize: 15,

            claimWidth: 120,
            claimHeight: 28,
            claimTrailing: 16,

            contentLiftY: -3
        )

        static func metrics(forWidth w: CGFloat) -> Metrics {
            isCompact(w) ? compact : regular
        }
    }

    private var items: [QuestItem] {
        QuestDefinitions.all.map { def in
            let raw = profile.questProgressValue(for: def.id)
            let current = min(raw, def.target)
            return QuestItem(
                id: def.id,
                title: def.title,
                current: current,
                target: def.target,
                rewardCoins: def.rewardCoins,
                isClaimed: profile.isClaimed(.quest, id: def.id)
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

                        list(m: m)
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
        GeometryReader { gp in
            let w = gp.size.width

            VStack(spacing: 0) {
                Image(Assets.header)
                    .resizable()
                    .scaledToFit()
                    .frame(width: floor(w * m.headerMaxWidthFactor))
                    .padding(.top, m.headerTopGap)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(height: m.headerHeight)
    }

    @ViewBuilder
    private func list(m: Layout.Metrics) -> some View {
        VStack(spacing: m.listSpacing) {
            ForEach(items) { item in
                questCard(m: m, item: item)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func questCard(m: Layout.Metrics, item: QuestItem) -> some View {
        let outer = RoundedRectangle(cornerRadius: m.cardCornerRadius, style: .continuous)
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
                Image(Assets.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: m.iconSize, height: m.iconSize)
                    .padding(.leading, m.iconLeading)

                VStack(alignment: .leading, spacing: 0) {
                    Text(item.title)
                        .font(Typography.font(size: m.titleSize))
                        .foregroundColor(Palette.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                        .padding(.top, m.titleTopPad)

                    VStack(alignment: .leading, spacing: 0) {
                        progressBar(m: m, current: item.current, target: item.target)

                        HStack(spacing: 6) {
                            Image(Assets.coin)
                                .resizable()
                                .scaledToFit()
                                .frame(width: m.rewardCoinSize, height: m.rewardCoinSize)

                            Text(Self.formatNumber(item.rewardCoins))
                                .font(Typography.font(size: m.rewardSize))
                                .foregroundColor(Palette.rewardText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)

                            Spacer(minLength: 0)

                            if item.isClaimed {
                                Text("Claimed")
                                    .font(Typography.font(size: 12))
                                    .foregroundColor(Palette.rewardText.opacity(0.7))
                            }
                        }
                        .padding(.top, m.rewardTopGap)
                    }
                    .padding(.top, m.progressTopGap)
                }
                .offset(y: m.contentLiftY)
                .padding(.leading, m.titleLeadingFromIcon)
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    profile.claimQuest(id: item.id)
                } label: {
                    Image(Assets.claim)
                        .resizable()
                        .scaledToFit()
                        .frame(width: m.claimWidth, height: m.claimHeight)
                        .opacity(claimEnabled ? 1.0 : 0.55)
                }
                .buttonStyle(.plain)
                .disabled(!claimEnabled)
                .padding(.trailing, m.claimTrailing)
            }
        }
        .frame(height: m.cardHeight)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func progressBar(m: Layout.Metrics, current: Int, target: Int) -> some View {
        let clamped = min(max(CGFloat(current) / CGFloat(max(1, target)), 0), 1)
        let progressLabel = "\(min(current, target))/\(target)"

        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: m.progressCornerRadius, style: .continuous)
                .fill(Palette.progressTrack)

            RoundedRectangle(cornerRadius: m.progressCornerRadius, style: .continuous)
                .stroke(Palette.progressStroke, lineWidth: m.progressStrokeWidth)

            GeometryReader { gp in
                let width = gp.size.width
                let fillW = max(0, floor(width * clamped))

                RoundedRectangle(cornerRadius: max(0, m.progressCornerRadius - m.progressInnerInset), style: .continuous)
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
                    .padding(m.progressInnerInset)
                    .animation(.easeInOut(duration: 0.35), value: fillW)
            }
            .clipShape(RoundedRectangle(cornerRadius: m.progressCornerRadius, style: .continuous))

            HStack(spacing: 0) {
                Spacer(minLength: 0)

                Text(progressLabel)
                    .font(Typography.font(size: m.progressLabelSize))
                    .foregroundColor(Palette.progressLabel)
                    .lineLimit(1)
                    .padding(.trailing, m.progressLabelTrailing)
            }
        }
        .frame(height: m.progressHeight)
    }

    private static func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
