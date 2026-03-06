// Path: UI/ProjectClubTabBar.swift

import SwiftUI
import UIKit

struct ProjectClubTabBar: View {
    enum Tab: Hashable {
        case lobby
        case achievs
        case game
        case quests
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

    static func preferredHeight(forWidth w: CGFloat) -> CGFloat {
        Layout.metrics(forWidth: w).height
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let m = Layout.metrics(forWidth: w)

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

                outer
                    .stroke(
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

                HStack(spacing: 0) {
                    ForEach(items) { item in
                        tabItem(m: m, item: item, isSelected: item.tab == selected)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, m.innerPadH)
                .padding(.top, m.itemTopPad)
                .padding(.bottom, m.innerBottomPad)
            }
            .frame(height: m.height)
            .frame(width: proxy.size.width, alignment: .center)
        }
        .frame(height: Self.preferredHeight(forWidth: UIScreen.main.bounds.width))
    }

    @ViewBuilder
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
                    .foregroundColor(Palette.text.opacity(isSelected ? 1.0 : 0.85))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
    }

    private enum Palette {
        static let fillA = Color(hex: "8E0509")
        static let fillB = Color(hex: "220207")
        static let strokeA = Color(hex: "FE8277")
        static let strokeB = Color(hex: "62090D")
        static let text = Color.white
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
            labelSize: 16,
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
            labelSize: 17,
            itemTopPad: 9,
            labelTopGap: 6,
            innerBottomPad: 9
        )

        static func metrics(forWidth w: CGFloat) -> Metrics {
            isCompact(w) ? compact : regular
        }
    }
}
