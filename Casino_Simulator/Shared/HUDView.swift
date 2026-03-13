// Path: UI/TopHUDView.swift
//Developer Chuong Nguyen

import SwiftUI
import UIKit

struct TopHUDView: View {
    let onOpenProfile: () -> Void

    @EnvironmentObject private var profile: GameCasProfSt
    @EnvironmentObject private var avatarStore: ProfileAvatarStore

    private enum Assets {
        static let money = "money"
        static let avatarPlaceholder = "avatar_placeholder"
    }

    private enum Palette {
        static let stroke = Color(hex: "B3130B")
        static let coinsFill = Color(hex: "0E0B12").opacity(0.22)
        static let avatarFill = Color.white.opacity(0.10)

        static let levelFill = LinearGradient(
            colors: [Color(hex: "8E0D18"), Color(hex: "56010A")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let coinsText = Color(hex: "FFF2C6")
        static let levelText = Color(hex: "FFFFFF")

        static let avatarInnerStroke = Color.white.opacity(0.10)
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
            let barHeight: CGFloat
            let barStroke: CGFloat
            let barCornerRadius: CGFloat
            let barInnerPadH: CGFloat
            let barContentSpacing: CGFloat

            let avatarSize: CGFloat
            let avatarStroke: CGFloat
            let avatarInnerInset: CGFloat

            let moneyIconSize: CGFloat
            let coinsFont: CGFloat
            let coinsMinScale: CGFloat

            let levelWidth: CGFloat
            let levelCornerRadius: CGFloat
            let levelFont: CGFloat

            let rowSpacing: CGFloat
        }

        static let compact = Metrics(
            barHeight: 34,
            barStroke: 2,
            barCornerRadius: 14,
            barInnerPadH: 12,
            barContentSpacing: 7,

            avatarSize: 46,
            avatarStroke: 2.6,
            avatarInnerInset: 3,

            moneyIconSize: 16,
            coinsFont: 16,
            coinsMinScale: 0.68,

            levelWidth: 44,
            levelCornerRadius: 10,
            levelFont: 16,

            rowSpacing: 12
        )

        static let regular = Metrics(
            barHeight: 38,
            barStroke: 2.3,
            barCornerRadius: 16,
            barInnerPadH: 14,
            barContentSpacing: 8,

            avatarSize: 52,
            avatarStroke: 3.0,
            avatarInnerInset: 3.5,

            moneyIconSize: 18,
            coinsFont: 18,
            coinsMinScale: 0.72,

            levelWidth: 50,
            levelCornerRadius: 10,
            levelFont: 18,

            rowSpacing: 14
        )

        static func metrics(forWidth w: CGFloat) -> Metrics {
            isCompact(w) ? compact : regular
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = Layout.metrics(forWidth: proxy.size.width)

            HStack(spacing: metrics.rowSpacing) {
                profileButton(m: metrics)

                coinsBar(m: metrics)
                    .frame(maxWidth: .infinity)

                levelBadge(m: metrics)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: metrics.barHeight,
                maxHeight: metrics.barHeight,
                alignment: .center
            )
        }
        .frame(height: Layout.metrics(forWidth: UIScreen.main.bounds.width).barHeight)
    }

    @ViewBuilder
    private func profileButton(m: Layout.Metrics) -> some View {
        Button(action: onOpenProfile) {
            ZStack {
                Circle().fill(Palette.avatarFill)

                avatarContent(m: m)
            }
            .overlay(Circle().stroke(Palette.stroke, lineWidth: m.avatarStroke))
            .frame(width: m.avatarSize, height: m.avatarSize)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
    }

    @ViewBuilder
    private func avatarContent(m: Layout.Metrics) -> some View {
        let innerSide = m.avatarSize - (m.avatarInnerInset * 2)

        if let image = avatarStore.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: innerSide, height: innerSide)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Palette.avatarInnerStroke, lineWidth: 1)
                        .padding(m.avatarInnerInset)
                )
        } else {
            Image(Assets.avatarPlaceholder)
                .resizable()
                .scaledToFill()
                .frame(width: innerSide, height: innerSide)
                .clipShape(Circle())
        }
    }

    @ViewBuilder
    private func coinsBar(m: Layout.Metrics) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: m.barCornerRadius, style: .continuous)
                .fill(Palette.coinsFill)

            RoundedRectangle(cornerRadius: m.barCornerRadius, style: .continuous)
                .stroke(Palette.stroke, lineWidth: m.barStroke)

            HStack(spacing: m.barContentSpacing) {
                Image(Assets.money)
                    .resizable()
                    .scaledToFit()
                    .frame(width: m.moneyIconSize, height: m.moneyIconSize)

                Text(Self.formatNumber(profile.coins))
                    .font(Typography.font(size: m.coinsFont))
                    .foregroundColor(Palette.coinsText)
                    .lineLimit(1)
                    .minimumScaleFactor(m.coinsMinScale)
            }
            .padding(.horizontal, m.barInnerPadH)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: m.barHeight)
        .accessibilityLabel("Coins")
        .accessibilityValue("\(profile.coins)")
    }

    @ViewBuilder
    private func levelBadge(m: Layout.Metrics) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: m.levelCornerRadius, style: .continuous)
                .fill(Palette.levelFill)

            RoundedRectangle(cornerRadius: m.levelCornerRadius, style: .continuous)
                .stroke(Palette.stroke, lineWidth: m.barStroke)

            Text("\(profile.level)")
                .font(Typography.font(size: m.levelFont))
                .foregroundColor(Palette.levelText)
        }
        .frame(width: m.levelWidth, height: m.barHeight)
        .accessibilityLabel("Level")
        .accessibilityValue("\(profile.level)")
    }

    private static func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
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

        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
