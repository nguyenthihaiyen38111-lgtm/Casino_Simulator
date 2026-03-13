// Path: DailyChallenge/DailyChallengeView.swift
//Developer Chuong Nguyen

import SwiftUI
import UIKit

struct DailyChallengeView: View {
    let onClose: () -> Void
    let onPlay: (GameCasProfSt.CasinoMode) -> Void

    @EnvironmentObject private var profile: GameCasProfSt

    @State private var glow = false
    @State private var breathe = false

    private enum Assets {
        static let background = "back_lobby"
        static let tag = "Quests"
        static let close = "arrowleft"
        static let coin = "money"
    }

    private enum Palette {
        static let cardFill = Color.black.opacity(0.25)
        static let cardStroke = Color.white.opacity(0.12)
        static let title = Color.white
        static let sub = Color.white.opacity(0.78)
        static let good = Color(hex: "81E456")
        static let warn = Color(hex: "FDF2B7")
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let isCompact = w <= 375

            let topInset: CGFloat = isCompact ? 26 : 30
            let sideInset: CGFloat = isCompact ? 22 : 26
            let cardCorner: CGFloat = isCompact ? 18 : 20

            ZStack {
                Image(Assets.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerBar(topInset: topInset, sideInset: sideInset)

                        challengeCard(isCompact: isCompact, sideInset: sideInset, corner: cardCorner)
                            .padding(.top, isCompact ? 14 : 18)

                        rulesCard(isCompact: isCompact, sideInset: sideInset, corner: cardCorner)
                            .padding(.top, isCompact ? 14 : 18)

                        actionArea(isCompact: isCompact, sideInset: sideInset)
                            .padding(.top, isCompact ? 18 : 22)

                        Spacer(minLength: 0).frame(height: proxy.safeAreaInsets.bottom + 18)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    glow.toggle()
                    breathe.toggle()
                }
            }
        }
    }

    private func headerBar(topInset: CGFloat, sideInset: CGFloat) -> some View {
        HStack(spacing: 12) {
            Button {
                haptic()
                onClose()
            } label: {
                Image(Assets.close)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Image(Assets.tag)
                .resizable()
                .scaledToFit()
                .frame(height: 44)
                .opacity(0.92)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Image(Assets.coin)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                Text(formatted(profile.coins))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Palette.title)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Palette.cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Palette.cardStroke, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.top, topInset)
        .padding(.horizontal, sideInset)
    }

    private func challengeCard(isCompact: Bool, sideInset: CGFloat, corner: CGFloat) -> some View {
        let c = profile.dailyChallenge

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Daily Challenge")
                        .font(.system(size: isCompact ? 24 : 28, weight: .heavy, design: .rounded))
                        .foregroundColor(Palette.title)

                    Text("Win points in a limited run and claim today’s reward.")
                        .font(.system(size: isCompact ? 13 : 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Palette.sub)
                }

                Spacer(minLength: 0)

                statusPill(c: c, isCompact: isCompact)
            }

            Divider().overlay(Color.white.opacity(0.10))

            HStack(spacing: 14) {
                statBlock(title: "Mode", value: c.mode.title, isCompact: isCompact)
                statBlock(title: "Fixed Bet", value: formatted(c.fixedBet), isCompact: isCompact)
                statBlock(title: "Spin Limit", value: "\(c.spinLimit)", isCompact: isCompact)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Progress")
                    .font(.system(size: isCompact ? 14 : 15, weight: .bold, design: .rounded))
                    .foregroundColor(Palette.title.opacity(0.92))

                progressStrip(value: c.netEarned, target: max(1, c.targetNet))
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Target Net")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Palette.sub)
                    Text(formatted(c.targetNet))
                        .font(.system(size: isCompact ? 18 : 20, weight: .heavy, design: .rounded))
                        .foregroundColor(Palette.warn)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 3) {
                    Text("Reward")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Palette.sub)
                    Text("+\(formatted(c.rewardCoins))")
                        .font(.system(size: isCompact ? 18 : 20, weight: .heavy, design: .rounded))
                        .foregroundColor(Palette.good)
                }
            }
        }
        .padding(.horizontal, isCompact ? 16 : 18)
        .padding(.vertical, isCompact ? 16 : 18)
        .background(Palette.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(Palette.cardStroke, lineWidth: 1.5)
                .opacity(glow ? 1.0 : 0.55)
        )
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .padding(.horizontal, sideInset)
        .scaleEffect(breathe ? 1.0 : 0.992)
        .animation(.easeInOut(duration: 0.9), value: breathe)
    }

    private func rulesCard(isCompact: Bool, sideInset: CGFloat, corner: CGFloat) -> some View {
        let c = profile.dailyChallenge

        return VStack(alignment: .leading, spacing: 12) {
            Text("Rules")
                .font(.system(size: isCompact ? 18 : 20, weight: .heavy, design: .rounded))
                .foregroundColor(Palette.title)

            ruleLine(text: "You must play the selected mode.", isCompact: isCompact)
            ruleLine(text: "Bet is fixed for the challenge.", isCompact: isCompact)
            ruleLine(text: "The challenge ends when you hit the target net or reach the spin limit.", isCompact: isCompact)
            ruleLine(text: "Once completed, claim the reward and a new challenge arrives tomorrow.", isCompact: isCompact)

            Divider().overlay(Color.white.opacity(0.10))

            HStack(spacing: 12) {
                Text("Current")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Palette.sub)

                Spacer(minLength: 0)

                Text("\(formatted(c.netEarned)) / \(formatted(c.targetNet)) net  •  \(c.spinsUsed)/\(c.spinLimit) spins")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Palette.title.opacity(0.86))
            }
        }
        .padding(.horizontal, isCompact ? 16 : 18)
        .padding(.vertical, isCompact ? 16 : 18)
        .background(Palette.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(Palette.cardStroke, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .padding(.horizontal, sideInset)
    }

    private func actionArea(isCompact: Bool, sideInset: CGFloat) -> some View {
        let c = profile.dailyChallenge

        return VStack(spacing: 12) {
            Button {
                haptic()
                onPlay(c.mode)
            } label: {
                Text("Play \(c.mode.title)")
                    .font(.system(size: isCompact ? 18 : 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.black.opacity(0.78))
                    .frame(maxWidth: .infinity)
                    .frame(height: isCompact ? 56 : 60)
                    .background(Color.white.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {
                haptic()
                profile.claimDailyChallengeReward()
            } label: {
                Text(c.isCompleted ? (c.isClaimed ? "Reward Claimed" : "Claim Reward") : "Complete to Claim")
                    .font(.system(size: isCompact ? 16 : 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(c.isCompleted && !c.isClaimed ? 1 : 0.6))
                    .frame(maxWidth: .infinity)
                    .frame(height: isCompact ? 54 : 58)
                    .background(Color.black.opacity(0.30))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(c.isCompleted && !c.isClaimed ? 0.22 : 0.10), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!c.isCompleted || c.isClaimed)
        }
        .padding(.horizontal, sideInset)
    }

    private func statusPill(c: GameCasProfSt.DailyChallengeSnapshot, isCompact: Bool) -> some View {
        let text: String
        let color: Color

        if c.isClaimed {
            text = "CLAIMED"
            color = Palette.good
        } else if c.isCompleted {
            text = "READY"
            color = Palette.warn
        } else {
            text = "LIVE"
            color = Color.white.opacity(0.85)
        }

        return Text(text)
            .font(.system(size: isCompact ? 12 : 13, weight: .heavy, design: .rounded))
            .foregroundColor(.black.opacity(0.72))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color)
            .clipShape(Capsule())
    }

    private func statBlock(title: String, value: String, isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Palette.sub.opacity(0.8))
            Text(value)
                .font(.system(size: isCompact ? 16 : 18, weight: .heavy, design: .rounded))
                .foregroundColor(Palette.title.opacity(0.92))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func ruleLine(text: String, isCompact: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.white.opacity(0.80))
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(.system(size: isCompact ? 13 : 14, weight: .semibold, design: .rounded))
                .foregroundColor(Palette.title.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func progressStrip(value: Int, target: Int) -> some View {
        let clamped = max(0, min(1.0, Double(value) / Double(target)))

        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.10))
                .frame(height: 14)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.75))
                .frame(width: max(14, CGFloat(clamped) * 320), height: 14)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
    }

    private func formatted(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func haptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
