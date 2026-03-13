// Path: Unlocks/UnlocksView.swift
//Developer Chuong Nguyen

import SwiftUI
import UIKit

struct UnlocksView: View {
    let bottomInset: CGFloat

    @EnvironmentObject private var profile: GameCasProfSt

    private enum Assets {
        static let background = "back_lobby"
        static let header = "crown"
        static let coin = "money"
        static let claim = "claim"
    }

    private enum Palette {
        static let title = Color(hex: "FDF2B7")
        static let secondary = Color(hex: "E8C8C2")
        static let disabled = Color.white.opacity(0.45)

        static let cardStrokeA = Color(hex: "E92933")
        static let cardStrokeB = Color(hex: "B51B2D")
        static let cardFillA = Color(hex: "5D0204")
        static let cardFillB = Color(hex: "510104")

        static let progressStroke = Color(hex: "864325")
        static let progressTrack = Color(hex: "140100")
        static let progressFillA = Color(hex: "C1E78C")
        static let progressFillB = Color(hex: "048601")

        static let statusLocked = Color.white.opacity(0.85)
        static let statusUnlocked = Color(hex: "C1E78C")
        static let statusClaimed = Color(hex: "FBB339")
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
            let headerSize: CGFloat
            let headerTitleSize: CGFloat
            let headerRowGap: CGFloat

            let listTopGap: CGFloat
            let listSpacing: CGFloat

            let cardCornerRadius: CGFloat
            let cardStrokeWidth: CGFloat
            let cardPadH: CGFloat
            let cardPadV: CGFloat

            let iconSize: CGFloat
            let titleSize: CGFloat
            let subtitleSize: CGFloat

            let statusSize: CGFloat
            let statusPadH: CGFloat
            let statusPadV: CGFloat
            let statusCorner: CGFloat

            let progressHeight: CGFloat
            let progressCorner: CGFloat
            let progressStrokeWidth: CGFloat
            let progressInnerInset: CGFloat

            let reqRowGap: CGFloat
            let reqTitleSize: CGFloat
            let reqValueSize: CGFloat

            let rewardRowTopGap: CGFloat
            let rewardSize: CGFloat
            let claimWidth: CGFloat
            let claimHeight: CGFloat
        }

        static let compact = Metrics(
            sideInset: 22,
            topInset: 28,
            headerSize: 54,
            headerTitleSize: 24,
            headerRowGap: 12,

            listTopGap: 16,
            listSpacing: 14,

            cardCornerRadius: 20,
            cardStrokeWidth: 3,
            cardPadH: 16,
            cardPadV: 16,

            iconSize: 54,
            titleSize: 18,
            subtitleSize: 12,

            statusSize: 12,
            statusPadH: 12,
            statusPadV: 7,
            statusCorner: 16,

            progressHeight: 16,
            progressCorner: 12,
            progressStrokeWidth: 2,
            progressInnerInset: 2,

            reqRowGap: 8,
            reqTitleSize: 12,
            reqValueSize: 12,

            rewardRowTopGap: 12,
            rewardSize: 20,
            claimWidth: 92,
            claimHeight: 46
        )

        static let regular = Metrics(
            sideInset: 24,
            topInset: 30,
            headerSize: 60,
            headerTitleSize: 26,
            headerRowGap: 12,

            listTopGap: 18,
            listSpacing: 16,

            cardCornerRadius: 22,
            cardStrokeWidth: 3.5,
            cardPadH: 18,
            cardPadV: 18,

            iconSize: 60,
            titleSize: 20,
            subtitleSize: 13,

            statusSize: 13,
            statusPadH: 12,
            statusPadV: 8,
            statusCorner: 18,

            progressHeight: 18,
            progressCorner: 13,
            progressStrokeWidth: 2.5,
            progressInnerInset: 2,

            reqRowGap: 9,
            reqTitleSize: 13,
            reqValueSize: 13,

            rewardRowTopGap: 14,
            rewardSize: 22,
            claimWidth: 100,
            claimHeight: 50
        )

        static func metrics(forWidth w: CGFloat) -> Metrics {
            isCompact(w) ? compact : regular
        }
    }

    private var items: [GameCasProfSt.UnlockCardModel] {
        profile.unlockCards
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

                        LazyVStack(spacing: m.listSpacing) {
                            ForEach(items) { item in
                                unlockCard(m: m, item: item)
                            }
                        }
                        .padding(.top, m.listTopGap)
                        .padding(.horizontal, m.sideInset)

                        Spacer(minLength: 0)
                            .frame(height: bottomInset)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func header(m: Layout.Metrics) -> some View {
        HStack(spacing: m.headerRowGap) {
            Image(Assets.header)
                .resizable()
                .scaledToFit()
                .frame(width: m.headerSize, height: m.headerSize)

            Text("Unlocks")
                .font(Typography.font(size: m.headerTitleSize))
                .foregroundColor(Palette.title)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Image(Assets.coin)
                    .resizable()
                    .scaledToFit()
                    .frame(width: m.rewardSize, height: m.rewardSize)

                Text(formatNumber(profile.coins))
                    .font(.system(size: m.reqValueSize + 2, weight: .heavy, design: .rounded))
                    .foregroundColor(Palette.title)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.22))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .padding(.top, m.topInset)
        .padding(.horizontal, m.sideInset)
    }

    private func unlockCard(m: Layout.Metrics, item: GameCasProfSt.UnlockCardModel) -> some View {
        let claimEnabled = item.isUnlocked && !item.isClaimed

        return ZStack {
            RoundedRectangle(cornerRadius: m.cardCornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Palette.cardFillA, location: 0.0),
                            .init(color: Palette.cardFillB, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: m.cardCornerRadius, style: .continuous)
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
                )

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 14) {
                    Image(item.iconAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(width: m.iconSize, height: m.iconSize)
                        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(Typography.font(size: m.titleSize))
                            .foregroundColor(Palette.title)
                            .lineLimit(2)

                        Text(item.subtitle)
                            .font(.system(size: m.subtitleSize, weight: .semibold, design: .rounded))
                            .foregroundColor(Palette.secondary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                    }

                    Spacer(minLength: 0)

                    statusPill(m: m, item: item)
                }

                Spacer().frame(height: 14)

                progressBar(m: m, percent: item.progressPercent)

                Spacer().frame(height: 14)

                VStack(alignment: .leading, spacing: m.reqRowGap) {
                    ForEach(item.requirements) { r in
                        requirementRow(m: m, r: r)
                    }
                }

                Spacer().frame(height: m.rewardRowTopGap)

                HStack(spacing: 10) {
                    Image(Assets.coin)
                        .resizable()
                        .scaledToFit()
                        .frame(width: m.rewardSize, height: m.rewardSize)

                    Text("+\(formatNumber(item.rewardCoins))")
                        .font(Typography.font(size: m.reqValueSize + 4))
                        .foregroundColor(Palette.title)

                    Spacer(minLength: 0)

                    Button {
                        profile.claimAchievement(id: item.rewardAchievementId)
                    } label: {
                        Image(Assets.claim)
                            .resizable()
                            .scaledToFit()
                            .frame(width: m.claimWidth, height: m.claimHeight)
                            .opacity(claimEnabled ? 1.0 : 0.55)
                    }
                    .buttonStyle(.plain)
                    .disabled(!claimEnabled)
                }
            }
            .padding(.horizontal, m.cardPadH)
            .padding(.vertical, m.cardPadV)
        }
        .clipShape(RoundedRectangle(cornerRadius: m.cardCornerRadius, style: .continuous))
    }

    private func statusPill(m: Layout.Metrics, item: GameCasProfSt.UnlockCardModel) -> some View {
        let text: String
        let color: Color

        if item.isClaimed {
            text = "CLAIMED"
            color = Palette.statusClaimed
        } else if item.isUnlocked {
            text = "UNLOCKED"
            color = Palette.statusUnlocked
        } else {
            text = "LOCKED"
            color = Palette.statusLocked
        }

        return Text(text)
            .font(.system(size: m.statusSize, weight: .heavy, design: .rounded))
            .foregroundColor(.black.opacity(0.72))
            .padding(.horizontal, m.statusPadH)
            .padding(.vertical, m.statusPadV)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: m.statusCorner, style: .continuous))
    }

    private func progressBar(m: Layout.Metrics, percent: Int) -> some View {
        let p = max(0, min(100, percent))
        let progress = CGFloat(p) / 100.0

        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: m.progressCorner, style: .continuous)
                .fill(Palette.progressTrack)
                .overlay(
                    RoundedRectangle(cornerRadius: m.progressCorner, style: .continuous)
                        .stroke(Palette.progressStroke, lineWidth: m.progressStrokeWidth)
                )
                .frame(height: m.progressHeight)

            GeometryReader { g in
                let w = max(0, g.size.width - (m.progressInnerInset * 2))
                let fill = max(0, min(w, w * progress))

                RoundedRectangle(cornerRadius: max(2, m.progressCorner - 3), style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Palette.progressFillA, location: 0.0),
                                .init(color: Palette.progressFillB, location: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fill, height: max(0, m.progressHeight - (m.progressInnerInset * 2)))
                    .padding(.leading, m.progressInnerInset)
                    .padding(.vertical, m.progressInnerInset)
            }
            .frame(height: m.progressHeight)
        }
    }

    private func requirementRow(m: Layout.Metrics, r: GameCasProfSt.UnlockRequirement) -> some View {
        let completed = r.isCompleted

        return HStack(spacing: 10) {
            Image(systemName: completed ? "checkmark.seal.fill" : "circle")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(completed ? Palette.statusUnlocked : Palette.secondary.opacity(0.9))

            Text(r.title)
                .font(.system(size: m.reqTitleSize, weight: .bold, design: .rounded))
                .foregroundColor(Palette.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            Text(requirementValueText(r))
                .font(.system(size: m.reqValueSize, weight: .heavy, design: .rounded))
                .foregroundColor(Palette.title)
        }
    }

    private func requirementValueText(_ r: GameCasProfSt.UnlockRequirement) -> String {
        switch r.kind {
        case .seconds:
            return "\(profile.formattedPlaytime(seconds: r.current)) / \(profile.formattedPlaytime(seconds: r.target))"
        default:
            return "\(formatNumber(r.current)) / \(formatNumber(r.target))"
        }
    }

    private func formatNumber(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
