// Path: Casino_Simulator/Content/OnboardingView.swift
//Developer Chuong Nguyen

import SwiftUI
import UIKit

struct OnboardingView: View {
    let onFinish: () -> Void

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var selection = 0
    @State private var animateScene = false
    @State private var animateCard = false
    @State private var contentOffset: CGFloat = 0

    private let pages: [OnboardingPage] = [
        .init(
            title: "Welcome to the simulator",
            subtitle: "Enjoy virtual sessions, smooth progression, and a polished casual experience built for short play.",
            category: "SIMULATOR",
            accent: Color(hex: "C43C2E"),
            accentSecondary: Color(hex: "E1A24C"),
            accentSoft: Color(hex: "F6E6D2"),
            icon: "sparkles",
            highlights: [
                "Virtual entertainment only",
                "Quick game sessions",
                "Clean local progress"
            ]
        ),
        .init(
            title: "Simple gameplay flow",
            subtitle: "Choose a mode, use virtual coins, complete rounds, and track your in-app results over time.",
            category: "GAMEPLAY",
            accent: Color(hex: "9E1F2D"),
            accentSecondary: Color(hex: "D78333"),
            accentSoft: Color(hex: "F7E4D7"),
            icon: "gamecontroller.fill",
            highlights: [
                "Choose a game mode",
                "Play with virtual balance",
                "Track session results"
            ]
        ),
        .init(
            title: "Play to unlock more",
            subtitle: "Progress through the app to open extra game modes and gradually expand what is available.",
            category: "PROGRESSION",
            accent: Color(hex: "7D1323"),
            accentSecondary: Color(hex: "D4A548"),
            accentSoft: Color(hex: "F4E4D7"),
            icon: "lock.open.fill",
            highlights: [
                "Unlock new games",
                "Expand available content",
                "Grow your collection"
            ]
        ),
        .init(
            title: "Everything in one place",
            subtitle: "Different game modes, profile progress, and a cleaner casual interface designed for quick use.",
            category: "FEATURES",
            accent: Color(hex: "B12F2F"),
            accentSecondary: Color(hex: "F0B24F"),
            accentSoft: Color(hex: "F8E7D7"),
            icon: "square.grid.2x2.fill",
            highlights: [
                "Several game modes",
                "Profile progression",
                "Modern visual style"
            ]
        ),
        .init(
            title: "Entertainment only",
            subtitle: "This app uses virtual mechanics only and does not include real-value gameplay or rewards.",
            category: "INFO",
            accent: Color(hex: "8B1E2A"),
            accentSecondary: Color(hex: "E0A14A"),
            accentSoft: Color(hex: "F7E7D8"),
            icon: "shield.fill",
            highlights: [
                "Virtual mechanics only",
                "No real-value play",
                "Made for entertainment"
            ]
        )
    ]

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom
            let isCompact = size.width <= 375

            ZStack {
                backgroundLayer(page: currentPage, size: size)

                VStack(spacing: 0) {
                    header(
                        safeTop: safeTop,
                        isCompact: isCompact
                    )

                    TabView(selection: $selection) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            pageContent(
                                page: page,
                                size: size,
                                safeTop: safeTop,
                                safeBottom: safeBottom,
                                isCompact: isCompact
                            )
                            .tag(index)
                            .padding(.horizontal, isCompact ? 18 : 24)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 6.5).repeatForever(autoreverses: true)) {
                    animateScene = true
                }

                withAnimation(.spring(response: 0.95, dampingFraction: 0.78).repeatForever(autoreverses: true)) {
                    animateCard = true
                }
            }
            .onChange(of: selection) { _, _ in
                contentOffset = 16
                withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                    contentOffset = 0
                }
            }
        }
    }

    private var currentPage: OnboardingPage {
        pages[selection]
    }

    private func backgroundLayer(page: OnboardingPage, size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "2B0608"),
                    Color(hex: "4D0912"),
                    Color(hex: "160304")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(page.accent.opacity(0.24))
                .frame(width: size.width * 0.68, height: size.width * 0.68)
                .blur(radius: 48)
                .offset(
                    x: animateScene ? -size.width * 0.16 : -size.width * 0.08,
                    y: animateScene ? -size.height * 0.16 : -size.height * 0.10
                )

            Circle()
                .fill(page.accentSecondary.opacity(0.18))
                .frame(width: size.width * 0.54, height: size.width * 0.54)
                .blur(radius: 52)
                .offset(
                    x: animateScene ? size.width * 0.20 : size.width * 0.10,
                    y: animateScene ? size.height * 0.18 : size.height * 0.10
                )

            RoundedRectangle(cornerRadius: 130, style: .continuous)
                .fill(Color.white.opacity(0.035))
                .frame(width: size.width * 0.95, height: size.height * 0.82)
                .rotationEffect(.degrees(-8))
                .offset(x: -size.width * 0.24, y: -size.height * 0.02)

            RoundedRectangle(cornerRadius: 120, style: .continuous)
                .fill(Color.white.opacity(0.025))
                .frame(width: size.width * 0.84, height: size.height * 0.60)
                .rotationEffect(.degrees(10))
                .offset(x: size.width * 0.24, y: size.height * 0.18)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.06),
                    Color.clear,
                    Color.black.opacity(0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private func header(
        safeTop: CGFloat,
        isCompact: Bool
    ) -> some View {
        HStack {
            HStack(spacing: 4) {
                Text("\(selection + 1)")
                    .font(displayFont(size: isCompact ? 20 : 22))
                    .foregroundColor(Color(hex: "F8E8D1"))

                Text("/ \(pages.count)")
                    .font(.system(size: isCompact ? 14 : 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.68))
            }
            .padding(.horizontal, 16)
            .frame(height: isCompact ? 44 : 46)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )

            Spacer()

            Button {
                finishOnboarding()
            } label: {
                Text("Skip")
                    .font(.system(size: isCompact ? 14 : 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "FFF2DD"))
                    .padding(.horizontal, 18)
                    .frame(height: isCompact ? 44 : 46)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.07))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, isCompact ? 20 : 24)
        .padding(.top, safeTop + 8)
        .padding(.bottom, 8)
    }

    private func pageContent(
        page: OnboardingPage,
        size: CGSize,
        safeTop: CGFloat,
        safeBottom: CGFloat,
        isCompact: Bool
    ) -> some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: isCompact ? 18 : 22) {
                    Spacer()
                        .frame(height: isCompact ? 12 : 18)

                    topIllustration(
                        page: page,
                        isCompact: isCompact
                    )

                    infoCard(
                        page: page,
                        isCompact: isCompact
                    )

                    Spacer()
                        .frame(height: isCompact ? 130 : 146)
                }
                .frame(maxWidth: .infinity)
                .offset(y: contentOffset)
            }
            .scrollBounceBehavior(.basedOnSize)

            footer(
                safeBottom: safeBottom,
                isCompact: isCompact
            )
            .background(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(hex: "220406").opacity(0.82),
                        Color(hex: "220406").opacity(0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    private func topIllustration(
        page: OnboardingPage,
        isCompact: Bool
    ) -> some View {
        let panelWidth: CGFloat = isCompact ? 260 : 292
        let panelHeight: CGFloat = isCompact ? 228 : 254
        let orbSize: CGFloat = isCompact ? 88 : 98
        let miniCardSize: CGFloat = isCompact ? 78 : 88

        return ZStack {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.13),
                            page.accentSoft.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: panelWidth, height: panelHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: page.accent.opacity(0.20), radius: 30, x: 0, y: 20)
                .overlay(alignment: .topLeading) {
                    Circle()
                        .fill(page.accent.opacity(0.20))
                        .frame(width: 132, height: 132)
                        .blur(radius: 18)
                        .offset(x: -24, y: -24)
                }
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .fill(page.accentSecondary.opacity(0.16))
                        .frame(width: 120, height: 120)
                        .blur(radius: 22)
                        .offset(x: 18, y: 18)
                }

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            page.accent.opacity(0.95),
                            page.accentSecondary.opacity(0.90)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: miniCardSize, height: miniCardSize)
                .overlay(
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                        .foregroundColor(.white.opacity(0.98))
                )
                .shadow(color: page.accent.opacity(0.36), radius: 22, x: 0, y: 14)
                .rotationEffect(.degrees(-12))
                .offset(x: isCompact ? -74 : -88, y: isCompact ? -14 : -18)
                .offset(y: animateCard ? -7 : 5)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "FFF4E5").opacity(0.92),
                            page.accentSoft.opacity(0.76)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: isCompact ? 106 : 118, height: isCompact ? 86 : 96)
                .overlay(
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(page.accentSecondary.opacity(0.85))
                            .frame(width: 42, height: 8)

                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(page.accent.opacity(0.42))
                                .frame(width: 14, height: 20)

                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(page.accent.opacity(0.68))
                                .frame(width: 14, height: 30)

                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(page.accentSecondary.opacity(0.92))
                                .frame(width: 14, height: 18)
                        }
                    }
                )
                .shadow(color: Color.black.opacity(0.16), radius: 20, x: 0, y: 14)
                .rotationEffect(.degrees(10))
                .offset(x: isCompact ? 84 : 96, y: isCompact ? -18 : -22)
                .offset(y: animateCard ? 6 : -5)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "FFF5E8"),
                            Color(hex: "F2D7B0")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: orbSize, height: orbSize)
                .shadow(color: page.accentSecondary.opacity(0.24), radius: 18, x: 0, y: 10)
                .overlay(
                    Image(systemName: page.icon)
                        .font(.system(size: isCompact ? 28 : 32, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    page.accent,
                                    page.accentSecondary
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .offset(y: animateCard ? -8 : 8)

            Circle()
                .fill(page.accentSecondary.opacity(0.25))
                .frame(width: 18, height: 18)
                .offset(x: isCompact ? 92 : 108, y: isCompact ? -74 : -86)

            Circle()
                .fill(page.accent.opacity(0.20))
                .frame(width: 12, height: 12)
                .offset(x: isCompact ? -96 : -112, y: isCompact ? 56 : 62)

            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(Color.black.opacity(0.22))
                .frame(width: isCompact ? 98 : 108, height: 14)
                .blur(radius: 12)
                .offset(y: isCompact ? 90 : 102)
        }
        .frame(height: isCompact ? 244 : 274)
        .padding(.top, isCompact ? 10 : 14)
    }

    private func infoCard(
        page: OnboardingPage,
        isCompact: Bool
    ) -> some View {
        VStack(spacing: 0) {
            Text(page.category)
                .font(.system(size: isCompact ? 11 : 12, weight: .black, design: .rounded))
                .tracking(1.4)
                .foregroundColor(Color(hex: "3B2217"))
                .padding(.horizontal, 18)
                .frame(height: isCompact ? 34 : 36)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FAE6C8"),
                                    Color(hex: "E6B970")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )

            Spacer().frame(height: isCompact ? 18 : 22)

            Text(page.title)
                .font(displayFont(size: isCompact ? 31 : 36))
                .foregroundColor(Color(hex: "FFF0DA"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.74)
                .padding(.horizontal, 14)

            Spacer().frame(height: 10)

            Text(page.subtitle)
                .font(.system(size: isCompact ? 15 : 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color.white.opacity(0.74))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, isCompact ? 16 : 22)

            Spacer().frame(height: isCompact ? 20 : 24)

            VStack(spacing: isCompact ? 10 : 12) {
                ForEach(page.highlights, id: \.self) { item in
                    highlightRow(
                        text: item,
                        page: page,
                        isCompact: isCompact
                    )
                }
            }
        }
        .padding(.horizontal, isCompact ? 16 : 20)
        .padding(.top, isCompact ? 20 : 24)
        .padding(.bottom, isCompact ? 20 : 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 30 : 34, style: .continuous)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 30 : 34, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 28, x: 0, y: 16)
        )
    }

    private func highlightRow(
        text: String,
        page: OnboardingPage,
        isCompact: Bool
    ) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            page.accentSecondary,
                            page.accent
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: isCompact ? 34 : 36, height: isCompact ? 34 : 36)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: isCompact ? 12 : 13, weight: .black))
                        .foregroundColor(Color.white)
                )
                .shadow(color: page.accentSecondary.opacity(0.24), radius: 10, x: 0, y: 6)

            Text(text)
                .font(.system(size: isCompact ? 14 : 15, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "FFF0DA"))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, isCompact ? 13 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func footer(
        safeBottom: CGFloat,
        isCompact: Bool
    ) -> some View {
        VStack(spacing: isCompact ? 16 : 18) {
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == selection
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        currentPage.accentSecondary,
                                        currentPage.accent
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            : AnyShapeStyle(Color.white.opacity(0.18))
                        )
                        .frame(width: index == selection ? 28 : 8, height: 8)
                        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: selection)
                }
            }

            HStack(spacing: 12) {
                if selection > 0 {
                    Button {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                            selection -= 1
                        }
                    } label: {
                        Text("Back")
                            .font(.system(size: isCompact ? 16 : 17, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "FFF0DA"))
                            .frame(maxWidth: .infinity)
                            .frame(height: isCompact ? 56 : 60)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    if selection == pages.count - 1 {
                        finishOnboarding()
                    } else {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                            selection += 1
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text(selection == pages.count - 1 ? "Start" : "Next")
                            .font(.system(size: isCompact ? 17 : 18, weight: .black, design: .rounded))

                        Image(systemName: selection == pages.count - 1 ? "checkmark" : "arrow.right")
                            .font(.system(size: isCompact ? 15 : 16, weight: .black))
                    }
                    .foregroundColor(Color(hex: "3B2217"))
                    .frame(maxWidth: .infinity)
                    .frame(height: isCompact ? 56 : 60)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        currentPage.accentSecondary,
                                        Color(hex: "F4C979"),
                                        currentPage.accent
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: currentPage.accentSecondary.opacity(0.22), radius: 18, x: 0, y: 10)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, isCompact ? 20 : 24)
        .padding(.top, 12)
        .padding(.bottom, max(safeBottom, 14))
    }

    private func finishOnboarding() {
        hasSeenOnboarding = true
        onFinish()
    }

    private func displayFont(size: CGFloat) -> Font {
        let candidates = [
            "MadimiOne-Regular",
            "MadimiOne_Regular",
            "MadimiOne Regular"
        ]

        for name in candidates where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }

        return .system(size: size, weight: .heavy, design: .rounded)
    }
}

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let category: String
    let accent: Color
    let accentSecondary: Color
    let accentSoft: Color
    let icon: String
    let highlights: [String]
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64

        switch cleaned.count {
        case 3:
            a = 255
            r = ((int >> 8) & 0xF) * 17
            g = ((int >> 4) & 0xF) * 17
            b = (int & 0xF) * 17
        case 6:
            a = 255
            r = int >> 16
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        case 8:
            a = int >> 24
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        default:
            a = 255
            r = 255
            g = 255
            b = 255
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
