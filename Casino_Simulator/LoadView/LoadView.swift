// Path: loadView/LoadView.swift

import SwiftUI
import UIKit

struct LoadView: View {
    let onFinish: () -> Void

    @State private var progress: CGFloat = 0
    @State private var didStart = false
    @State private var glow = false
    @State private var float = false
    @State private var rotateCoin = false

    private enum Assets {
        static let background = "back_lobby"
        static let coin = "money"
    }

    private enum Palette {
        static let overlayTop = Color.black.opacity(0.12)
        static let overlayBottom = Color.black.opacity(0.46)

        static let titleA = Color(hex: "FDF2B7")
        static let titleB = Color(hex: "FBB339")

        static let accentA = Color(hex: "FED631")
        static let accentB = Color(hex: "FC2702")

        static let barTrack = Color.black.opacity(0.30)
        static let barStroke = Color.white.opacity(0.10)
        static let barFillA = Color(hex: "FED631")
        static let barFillB = Color(hex: "FC2702")

        static let subtitle = Color.white.opacity(0.90)
        static let hint = Color.white.opacity(0.70)
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

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let isCompact = w <= 375

            let titleSize: CGFloat = isCompact ? 42 : 52
            let subtitleSize: CGFloat = isCompact ? 15 : 17
            let coinSize: CGFloat = isCompact ? 96 : 112
            let progressWidth: CGFloat = min(isCompact ? 240 : 290, w - 64)
            let progressHeight: CGFloat = isCompact ? 18 : 20

            ZStack {
                Image(Assets.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [Palette.overlayTop, Palette.overlayBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Palette.accentA.opacity(glow ? 0.34 : 0.18),
                                        Palette.accentB.opacity(0.10),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: coinSize * 1.2
                                )
                            )
                            .frame(width: coinSize * 2.1, height: coinSize * 2.1)
                            .blur(radius: glow ? 10 : 18)
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: glow)

                        Image(Assets.coin)
                            .resizable()
                            .scaledToFit()
                            .frame(width: coinSize, height: coinSize)
                            .rotationEffect(.degrees(rotateCoin ? 360 : 0))
                            .offset(y: float ? -8 : 8)
                            .shadow(color: Palette.accentA.opacity(0.35), radius: 16, x: 0, y: 8)
                            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: float)
                            .animation(.linear(duration: 2.6).repeatForever(autoreverses: false), value: rotateCoin)
                    }

                    Spacer()
                        .frame(height: isCompact ? 26 : 34)

                    LinearGradient(
                        colors: [Palette.titleA, Palette.titleB],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Text("Treasure Realms")
                            .font(Typography.font(size: titleSize))
                            .tracking(1)
                    )
                    .frame(height: titleSize + 10)

                    Spacer()
                        .frame(height: 8)

                    Text("Loading your game world")
                        .font(.system(size: subtitleSize, weight: .semibold, design: .rounded))
                        .foregroundColor(Palette.subtitle)

                    Spacer()
                        .frame(height: isCompact ? 26 : 30)

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: progressHeight / 2, style: .continuous)
                            .fill(Palette.barTrack)
                            .overlay(
                                RoundedRectangle(cornerRadius: progressHeight / 2, style: .continuous)
                                    .stroke(Palette.barStroke, lineWidth: 1)
                            )

                        GeometryReader { gp in
                            RoundedRectangle(cornerRadius: progressHeight / 2, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Palette.barFillA, Palette.barFillB],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(8, gp.size.width * progress), height: progressHeight)
                        }
                    }
                    .frame(width: progressWidth, height: progressHeight)

                    Spacer()
                        .frame(height: 12)

                    Text("\(Int(progress * 100))%")
                        .font(Typography.font(size: isCompact ? 16 : 18))
                        .foregroundColor(Palette.hint)

                    Spacer()
                }
                .padding(.bottom, isCompact ? 90 : 110)
            }
            .onAppear {
                guard !didStart else { return }
                didStart = true

                glow = true
                float = true
                rotateCoin = true

                withAnimation(.linear(duration: 5.0)) {
                    progress = 1.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    onFinish()
                }
            }
        }
    }
}

private extension Color {
    init(hex: String) {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r, g, b: UInt64
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

        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: 1.0
        )
    }
}
