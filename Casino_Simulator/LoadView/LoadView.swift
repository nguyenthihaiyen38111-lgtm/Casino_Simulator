// Path: loadView/LoadView.swift

import SwiftUI
import UIKit

struct LoadView: View {
    let onFinish: () -> Void

    private let loadingDuration: Double = 5.0

    @State private var didStart = false
    @State private var finished = false
    @State private var startDate: Date?

    @State private var glow = false
    @State private var floatCoin = false
    @State private var spinRing = false
    @State private var spinOrbit = false
    @State private var shimmer = false
    @State private var breathe = false

    private enum Assets {
        static let background = "back_lobby"
        static let coin = "money"
    }

    private enum Palette {
        static let topOverlay = Color.black.opacity(0.08)
        static let bottomOverlay = Color.black.opacity(0.58)

        static let goldA = Color(hex: "FFF4B0")
        static let goldB = Color(hex: "F8CF53")
        static let goldC = Color(hex: "F29A1F")
        static let redA = Color(hex: "FC5A1A")
        static let redB = Color(hex: "A80F0D")

        static let auraA = Color(hex: "FFE37D")
        static let auraB = Color(hex: "FF9B33")
        static let auraC = Color(hex: "FF5A2A")

        static let whiteSoft = Color.white.opacity(0.88)
        static let whiteDim = Color.white.opacity(0.68)

        static let cardFill = Color.black.opacity(0.20)

        static let ringTrack = Color.white.opacity(0.10)
        static let ringGlow = Color(hex: "FFD65C")
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
            let size = proxy.size
            let isCompact = size.width <= 375

            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
                let progress = currentProgress(at: timeline.date)
                let percent = min(100, max(0, Int((progress * 100).rounded())))
                let stage = stageText(for: progress)
                let hint = hintText(for: progress)

                ZStack {
                    Image(Assets.background)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(breathe ? 1.04 : 1.0)
                        .ignoresSafeArea()

                    LinearGradient(
                        colors: [Palette.topOverlay, Palette.bottomOverlay],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    ambientLights(size: size)
                    floatingParticles(size: size, compact: isCompact)

                    VStack(spacing: 0) {
                        Spacer(minLength: 0)

                        titleBlock(isCompact: isCompact)

                        Spacer()
                            .frame(height: isCompact ? 24 : 32)

                        loadingCore(
                            progress: progress,
                            percent: percent,
                            stage: stage,
                            hint: hint,
                            isCompact: isCompact
                        )

                        Spacer(minLength: 0)
                    }
                    .padding(.top, isCompact ? 62 : 78)
                    .padding(.bottom, isCompact ? 52 : 66)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .statusBarHidden(true)
            .task {
                await startLoading()
            }
        }
    }

    private func titleBlock(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 8 : 10) {
            Text("Velvet Lounge")
                .font(Typography.font(size: isCompact ? 40 : 52))
                .tracking(1.2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Palette.goldA, Palette.goldB, Palette.goldC],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Palette.ringGlow.opacity(glow ? 0.38 : 0.18), radius: glow ? 16 : 8, x: 0, y: 0)

            Text("Getting everything ready")
                .font(.system(size: isCompact ? 14 : 16, weight: .semibold, design: .rounded))
                .foregroundColor(Palette.whiteDim)
        }
    }

    private func loadingCore(
        progress: CGFloat,
        percent: Int,
        stage: String,
        hint: String,
        isCompact: Bool
    ) -> some View {
        let panelWidth: CGFloat = isCompact ? 300 : 340
        let panelHeight: CGFloat = isCompact ? 390 : 430
        let coreSize: CGFloat = isCompact ? 188 : 220
        let coinSize: CGFloat = isCompact ? 94 : 112

        return ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Palette.cardFill,
                            Color.black.opacity(0.30)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.07),
                                    Color.white.opacity(0.14)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.22), radius: 24, x: 0, y: 16)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: isCompact ? 24 : 28)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Palette.auraA.opacity(glow ? 0.34 : 0.18),
                                    Palette.auraB.opacity(0.16),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 8,
                                endRadius: coreSize * 0.75
                            )
                        )
                        .frame(width: coreSize * 1.55, height: coreSize * 1.55)
                        .blur(radius: glow ? 12 : 22)
                        .scaleEffect(glow ? 1.04 : 0.92)

                    Circle()
                        .stroke(Palette.ringTrack, lineWidth: isCompact ? 10 : 12)
                        .frame(width: coreSize, height: coreSize)

                    Circle()
                        .trim(from: 0, to: max(0.02, progress))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Palette.goldA,
                                    Palette.goldB,
                                    Palette.goldC,
                                    Palette.redA,
                                    Palette.goldA
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(
                                lineWidth: isCompact ? 10 : 12,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .frame(width: coreSize, height: coreSize)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Palette.ringGlow.opacity(0.34), radius: 10, x: 0, y: 0)

                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: coreSize - 34, height: coreSize - 34)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )

                    orbitDots(progress: progress, ringSize: coreSize)

                    Image(Assets.coin)
                        .resizable()
                        .scaledToFit()
                        .frame(width: coinSize, height: coinSize)
                        .rotationEffect(.degrees(spinRing ? 360 : 0))
                        .offset(y: floatCoin ? -7 : 7)
                        .shadow(color: Palette.goldB.opacity(0.34), radius: 18, x: 0, y: 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: coinSize * 0.28, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(shimmer ? 0.42 : 0.0),
                                            Color.white.opacity(0.0),
                                            Color.white.opacity(shimmer ? 0.18 : 0.0)
                                        ],
                                        startPoint: shimmer ? .topLeading : .bottomTrailing,
                                        endPoint: shimmer ? .bottomTrailing : .topLeading
                                    )
                                )
                                .rotationEffect(.degrees(14))
                                .blendMode(.screen)
                        )

                    VStack(spacing: 0) {
                        Spacer()
                        Text("\(percent)%")
                            .font(Typography.font(size: isCompact ? 24 : 28))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Palette.goldA, Palette.goldB],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .padding(.bottom, isCompact ? -132 : -152)
                    }
                    .frame(width: coreSize, height: coreSize)
                }
                .frame(height: coreSize + 36)

                Spacer()
                    .frame(height: isCompact ? 18 : 22)

                Text(stage)
                    .font(.system(size: isCompact ? 17 : 19, weight: .bold, design: .rounded))
                    .foregroundColor(Palette.whiteSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Spacer()
                    .frame(height: 8)

                Text(hint)
                    .font(.system(size: isCompact ? 13 : 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Palette.whiteDim)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()
                    .frame(height: isCompact ? 22 : 26)

                livePill(progress: progress, isCompact: isCompact)

                Spacer()
            }
            .frame(width: panelWidth, height: panelHeight)
        }
        .frame(width: panelWidth, height: panelHeight)
    }

    private func livePill(progress: CGFloat, isCompact: Bool) -> some View {
        let width: CGFloat = isCompact ? 220 : 244
        let height: CGFloat = isCompact ? 44 : 48

        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.white.opacity(0.07))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.09), lineWidth: 1)
                )

            GeometryReader { proxy in
                let fillWidth = max(height, proxy.size.width * progress)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Palette.goldA.opacity(0.92),
                                Palette.goldB.opacity(0.90),
                                Palette.redA.opacity(0.84)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fillWidth)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.32),
                                        Color.white.opacity(0.08),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: fillWidth, height: height * 0.62)
                            .padding(.top, 1)
                    }
                    .overlay(alignment: .trailing) {
                        Circle()
                            .fill(Color.white.opacity(0.96))
                            .frame(width: height - 8, height: height - 8)
                            .blur(radius: 0.2)
                            .shadow(color: Palette.ringGlow.opacity(0.55), radius: 10, x: 0, y: 0)
                            .padding(.trailing, 4)
                    }
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(Palette.whiteSoft)
                    .frame(width: 6, height: 6)
                    .opacity(glow ? 1.0 : 0.45)

                Text("Loading")
                    .font(.system(size: isCompact ? 13 : 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.70))
                    .opacity(progress > 0.12 ? 1 : 0)

                LoadingDotsView()
                    .opacity(progress > 0.12 ? 1 : 0)
            }
            .padding(.leading, 18)
        }
        .frame(width: width, height: height)
    }

    private func orbitDots(progress: CGFloat, ringSize: CGFloat) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                let angle = orbitAngle(for: index, progress: progress)
                let radius = ringSize / 2

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Palette.goldA, Palette.goldB],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: index == 0 ? 10 : 7, height: index == 0 ? 10 : 7)
                    .shadow(color: Palette.ringGlow.opacity(0.44), radius: 8, x: 0, y: 0)
                    .offset(
                        x: cos(angle) * radius,
                        y: sin(angle) * radius
                    )
                    .opacity(index == 0 ? 1.0 : 0.68)
            }
        }
        .rotationEffect(.degrees(spinOrbit ? 360 : 0))
    }

    private func orbitAngle(for index: Int, progress: CGFloat) -> CGFloat {
        let base = -CGFloat.pi / 2
        switch index {
        case 0:
            return base + (.pi * 2 * progress)
        case 1:
            return base + (.pi * 2 * progress) - 0.55
        default:
            return base + (.pi * 2 * progress) - 1.05
        }
    }

    private func ambientLights(size: CGSize) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Palette.auraA.opacity(0.16),
                            Palette.auraB.opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 240
                    )
                )
                .frame(width: 340, height: 340)
                .offset(x: -size.width * 0.26, y: -size.height * 0.18)
                .blur(radius: 12)
                .scaleEffect(breathe ? 1.10 : 0.92)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Palette.redA.opacity(0.12),
                            Palette.goldB.opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 12,
                        endRadius: 260
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: size.width * 0.28, y: size.height * 0.14)
                .blur(radius: 16)
                .scaleEffect(breathe ? 0.94 : 1.08)
        }
    }

    private func floatingParticles(size: CGSize, compact: Bool) -> some View {
        let points: [CGPoint] = compact
        ? [
            CGPoint(x: 0.12, y: 0.18), CGPoint(x: 0.86, y: 0.16), CGPoint(x: 0.18, y: 0.33),
            CGPoint(x: 0.84, y: 0.36), CGPoint(x: 0.10, y: 0.60), CGPoint(x: 0.80, y: 0.58),
            CGPoint(x: 0.22, y: 0.78), CGPoint(x: 0.90, y: 0.76), CGPoint(x: 0.50, y: 0.14)
        ]
        : [
            CGPoint(x: 0.10, y: 0.16), CGPoint(x: 0.88, y: 0.15), CGPoint(x: 0.16, y: 0.30),
            CGPoint(x: 0.85, y: 0.34), CGPoint(x: 0.10, y: 0.56), CGPoint(x: 0.83, y: 0.54),
            CGPoint(x: 0.23, y: 0.76), CGPoint(x: 0.90, y: 0.74), CGPoint(x: 0.50, y: 0.12),
            CGPoint(x: 0.67, y: 0.22), CGPoint(x: 0.32, y: 0.60)
        ]

        return ZStack {
            ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                FloatingParticle(delay: Double(index) * 0.18)
                    .position(x: size.width * point.x, y: size.height * point.y)
            }
        }
    }

    private func stageText(for progress: CGFloat) -> String {
        switch progress {
        case ..<0.34:
            return "Loading interface"
        case ..<0.74:
            return "Syncing your data"
        default:
            return "Finalizing setup"
        }
    }

    private func hintText(for progress: CGFloat) -> String {
        switch progress {
        case ..<0.34:
            return "Preparing visuals and app resources"
        case ..<0.74:
            return "Updating profile and local progress"
        default:
            return "Almost done — opening your home screen"
        }
    }

    private func currentProgress(at date: Date) -> CGFloat {
        guard let startDate else { return 0 }
        let elapsed = max(0, date.timeIntervalSince(startDate))
        let raw = min(1, elapsed / loadingDuration)
        return progressCurve(raw)
    }

    private func progressCurve(_ t: Double) -> CGFloat {
        if t <= 0.22 {
            let local = t / 0.22
            return CGFloat(0.28 * easeOutCubic(local))
        } else if t <= 0.56 {
            let local = (t - 0.22) / 0.34
            return CGFloat(0.28 + (0.38 * easeInOutCubic(local)))
        } else if t <= 0.82 {
            let local = (t - 0.56) / 0.26
            return CGFloat(0.66 + (0.18 * easeInOutCubic(local)))
        } else {
            let local = (t - 0.82) / 0.18
            return CGFloat(0.84 + (0.16 * easeOutCubic(local)))
        }
    }

    private func easeOutCubic(_ t: Double) -> Double {
        1 - pow(1 - t, 3)
    }

    private func easeInOutCubic(_ t: Double) -> Double {
        if t < 0.5 {
            return 4 * t * t * t
        } else {
            return 1 - pow(-2 * t + 2, 3) / 2
        }
    }

    @MainActor
    private func startLoading() async {
        guard !didStart else { return }
        didStart = true
        startDate = Date()

        glow = true
        floatCoin = true
        spinRing = true
        spinOrbit = true
        shimmer = true
        breathe = true

        try? await Task.sleep(nanoseconds: UInt64(loadingDuration * 1_000_000_000))

        guard !finished else { return }
        finished = true
        onFinish()
    }
}

private struct FloatingParticle: View {
    let delay: Double

    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(animate ? 0.9 : 0.25))
                .frame(width: animate ? 3.2 : 2.0, height: animate ? 3.2 : 2.0)
                .blur(radius: 0.15)

            Rectangle()
                .fill(Color.white.opacity(animate ? 0.55 : 0.12))
                .frame(width: 1, height: animate ? 11 : 6)
                .blur(radius: 0.2)

            Rectangle()
                .fill(Color.white.opacity(animate ? 0.55 : 0.12))
                .frame(width: animate ? 11 : 6, height: 1)
                .blur(radius: 0.2)
        }
        .scaleEffect(animate ? 1.08 : 0.72)
        .opacity(animate ? 1.0 : 0.35)
        .offset(y: animate ? -7 : 7)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true).delay(delay)) {
                animate = true
            }
        }
    }
}

private struct LoadingDotsView: View {
    @State private var phase = 0
    @State private var timer: Timer?

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.black.opacity(phase == index ? 0.76 : 0.28))
                    .frame(width: 4.5, height: 4.5)
            }
        }
        .onAppear {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.28, repeats: true) { _ in
                phase = (phase + 1) % 3
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
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

        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: 1.0
        )
    }
}
