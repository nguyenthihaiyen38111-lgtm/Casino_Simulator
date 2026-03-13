// Path: UI/ProjectClubTabBar.swift

import SwiftUI
import UIKit

struct ProjectClubTabBar: View {
    enum Tab: Hashable {
        case lobby
        case achievs
        case game
        case quests
        case unlocks
    }

    struct Item: Identifiable, Hashable {
        let id = UUID()
        let tab: Tab
        let icon: String
        let title: String
    }

    let items: [Item]
    let selected: Tab
    let onSelect: (Tab) -> Void
    let availableWidth: CGFloat

    static func preferredHeight(forWidth w: CGFloat) -> CGFloat {
        Layout.metrics(forWidth: w).height
    }

    var body: some View {
        let m = Layout.metrics(forWidth: availableWidth)
        let outer = RoundedRectangle(cornerRadius: m.cornerRadius, style: .continuous)

        ZStack {
            outer
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Palette.fillA, location: 0.0),
                            .init(color: Palette.fillB, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    outer.stroke(
                        LinearGradient(
                            stops: [
                                .init(color: Palette.strokeA, location: 0.0),
                                .init(color: Palette.strokeB, location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: m.strokeWidth
                    )
                )

            HStack(spacing: 0) {
                ForEach(items) { item in
                    tabItem(m: m, item: item, isSelected: item.tab == selected)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, m.innerPadH)
            .padding(.bottom, m.innerBottomPad)
        }
        .frame(height: m.height)
    }

    private func tabItem(m: Layout.Metrics, item: Item, isSelected: Bool) -> some View {
        Button {
            onSelect(item.tab)
        } label: {
            VStack(spacing: m.labelTopGap) {
                Image(item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: m.iconSize, height: m.iconSize)

                Text(item.title)
                    .font(Typography.font(size: m.labelSize))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .foregroundColor(Palette.text.opacity(isSelected ? 1.0 : 0.85))
            }
            .padding(.top, m.itemTopPad)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
    }

    private enum Palette {
        static let fillA = Color(hex: "5D0204")
        static let fillB = Color(hex: "510104")
        static let strokeA = Color(hex: "E92933")
        static let strokeB = Color(hex: "B51B2D")
        static let text = Color(hex: "FDF2B7")
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
            let height: CGFloat
            let cornerRadius: CGFloat
            let strokeWidth: CGFloat
            let innerPadH: CGFloat
            let iconSize: CGFloat
            let labelSize: CGFloat
            let itemTopPad: CGFloat
            let labelTopGap: CGFloat
            let innerBottomPad: CGFloat
        }

        static let compact = Metrics(
            height: 72,
            cornerRadius: 16,
            strokeWidth: 3,
            innerPadH: 16,
            iconSize: 28,
            labelSize: 14,
            itemTopPad: 8,
            labelTopGap: 6,
            innerBottomPad: 8
        )

        static let regular = Metrics(
            height: 80,
            cornerRadius: 18,
            strokeWidth: 3.5,
            innerPadH: 18,
            iconSize: 30,
            labelSize: 15,
            itemTopPad: 9,
            labelTopGap: 6,
            innerBottomPad: 9
        )

        static func metrics(forWidth w: CGFloat) -> Metrics {
            isCompact(w) ? compact : regular
        }
    }
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r: UInt64
        let g: UInt64
        let b: UInt64

        switch cleaned.count {
        case 6:
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
        default:
            r = 255
            g = 255
            b = 255
        }

        self.init(.sRGB, red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0, opacity: 1)
    }
}
