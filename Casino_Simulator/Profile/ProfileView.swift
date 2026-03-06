// Path: Profile/ProfileView.swift

import SwiftUI
import UIKit
import PhotosUI
import Photos

struct ProfileView: View {
    let onClose: () -> Void

    @EnvironmentObject private var profile: GameCasProfSt
    @EnvironmentObject private var avatarStore: ProfileAvatarStore

    @State private var isAvatarPickerPresented = false
    @State private var showPhotoAccessDeniedAlert = false
    @State private var showResetConfirm = false

    @State private var appear = false
    @State private var glowPulse = false

    private enum Assets {
        static let background = "back_lobby"
        static let avatarPlaceholder = "avatar_placeholder"
    }

    private enum Palette {
        static let overlayTop = Color.black.opacity(0.06)
        static let overlayMid = Color.black.opacity(0.22)
        static let overlayBottom = Color.black.opacity(0.42)

        static let cardFill = Color(hex: "1C0606").opacity(0.92)
        static let cardFillSoft = Color(hex: "140404").opacity(0.92)

        static let strokeA = Color(hex: "FFD98A").opacity(0.55)
        static let strokeB = Color(hex: "D88235").opacity(0.45)

        static let title = Color.white
        static let subtitle = Color(hex: "F6E6C2")
        static let bodySoft = Color.white.opacity(0.74)

        static let chipFill = Color.black.opacity(0.20)
        static let chipStroke = Color.white.opacity(0.10)

        static let iconBg = Color.black.opacity(0.22)

        static let trackFill = Color.black.opacity(0.28)
        static let trackStroke = Color.white.opacity(0.10)

        static let accentGreen = Color(hex: "8BFF63")
        static let accentOrange = Color(hex: "E99A4D")
        static let accentYellow = Color(hex: "F7C15F")
        static let accentRed = Color(hex: "FF8E7E")
    }

    private enum Layout {
        static func isCompact(_ width: CGFloat) -> Bool { width <= 375 }

        struct Metrics {
            let screenHorizontal: CGFloat
            let sectionSpacing: CGFloat
            let headerTopInset: CGFloat

            let backSize: CGFloat
            let backCorner: CGFloat
            let backIcon: CGFloat

            let headerTitleSize: CGFloat
            let headerSubtitleSize: CGFloat

            let bigCardCorner: CGFloat
            let bigCardPad: CGFloat

            let avatarSize: CGFloat
            let avatarStroke: CGFloat

            let actionHeight: CGFloat
            let actionCorner: CGFloat
            let actionFont: CGFloat
            let actionIcon: CGFloat

            let profileTitleSize: CGFloat

            let chipHeight: CGFloat
            let chipTitleSize: CGFloat
            let chipValueSize: CGFloat
            let chipHPad: CGFloat
            let chipSpacing: CGFloat

            let gridSpacing: CGFloat
            let statCardHeight: CGFloat
            let statValueSize: CGFloat
            let statTitleSize: CGFloat
            let statSubtitleSize: CGFloat
            let statIconSize: CGFloat

            let progressOuterCorner: CGFloat
            let progressInnerCorner: CGFloat
            let progressRowHeight: CGFloat
            let progressTitleSize: CGFloat
            let progressPercentSize: CGFloat
            let progressCaptionSize: CGFloat
        }

        static let compact = Metrics(
            screenHorizontal: 16,
            sectionSpacing: 14,
            headerTopInset: 6,

            backSize: 68,
            backCorner: 20,
            backIcon: 18,

            headerTitleSize: 22,
            headerSubtitleSize: 13,

            bigCardCorner: 20,
            bigCardPad: 14,

            avatarSize: 92,
            avatarStroke: 2.5,

            actionHeight: 48,
            actionCorner: 14,
            actionFont: 14,
            actionIcon: 15,

            profileTitleSize: 22,

            chipHeight: 34,
            chipTitleSize: 11,
            chipValueSize: 13,
            chipHPad: 10,
            chipSpacing: 5,

            gridSpacing: 12,
            statCardHeight: 144,
            statValueSize: 22,
            statTitleSize: 14,
            statSubtitleSize: 12,
            statIconSize: 18,

            progressOuterCorner: 20,
            progressInnerCorner: 16,
            progressRowHeight: 96,
            progressTitleSize: 15,
            progressPercentSize: 14,
            progressCaptionSize: 12
        )

        static let regular = Metrics(
            screenHorizontal: 20,
            sectionSpacing: 18,
            headerTopInset: 8,

            backSize: 76,
            backCorner: 22,
            backIcon: 20,

            headerTitleSize: 26,
            headerSubtitleSize: 15,

            bigCardCorner: 22,
            bigCardPad: 16,

            avatarSize: 108,
            avatarStroke: 3,

            actionHeight: 54,
            actionCorner: 16,
            actionFont: 16,
            actionIcon: 17,

            profileTitleSize: 28,

            chipHeight: 36,
            chipTitleSize: 13,
            chipValueSize: 15,
            chipHPad: 12,
            chipSpacing: 6,

            gridSpacing: 14,
            statCardHeight: 158,
            statValueSize: 26,
            statTitleSize: 16,
            statSubtitleSize: 13,
            statIconSize: 20,

            progressOuterCorner: 22,
            progressInnerCorner: 18,
            progressRowHeight: 108,
            progressTitleSize: 16,
            progressPercentSize: 15,
            progressCaptionSize: 13
        )

        static func metrics(for width: CGFloat) -> Metrics {
            isCompact(width) ? compact : regular
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let m = Layout.metrics(for: proxy.size.width)
            let safeTop = proxy.safeAreaInsets.top

            ZStack {
                Image(Assets.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ZStack {
                    LinearGradient(
                        colors: [Palette.overlayTop, Palette.overlayMid, Palette.overlayBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    RadialGradient(
                        colors: [
                            Color(hex: "FFB14A").opacity(0.06),
                            Color.black.opacity(0.02),
                            Color.black.opacity(0.28)
                        ],
                        center: .top,
                        startRadius: 40,
                        endRadius: 520
                    )
                }
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: m.sectionSpacing) {
                        header(safeTop: safeTop, m: m)
                        playerCard(m: m, isCompact: Layout.isCompact(proxy.size.width))
                        statsGrid(m: m)
                        progressCard(m: m)
                        resetProgressButton(m: m)
                    }
                    .padding(.horizontal, m.screenHorizontal)
                    .padding(.bottom, max(20, proxy.safeAreaInsets.bottom + 12))
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 14)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.92)) {
                appear = true
            }
            glowPulse = true
        }
        .sheet(isPresented: $isAvatarPickerPresented) {
            ProfileImagePicker { image in
                guard let image else { return }
                let prepared = image.profilePreparedAvatar(targetSide: 512)
                avatarStore.setImage(prepared)
            }
            .applyMediumDetentIfAvailable()
        }
        .alert("Photo Access Needed", isPresented: $showPhotoAccessDeniedAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
        } message: {
            Text("Please allow access to your photo library in Settings to choose an avatar.")
        }
        .confirmationDialog("Reset Progress?", isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("Reset Everything", role: .destructive) {
                profile.resetAllProgress()
                ProfileMetaStorage.shared.reset()
                avatarStore.removeImage()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will clear coins, level, quests, achievements and all progress. This action cannot be undone.")
        }
    }

    private func header(safeTop: CGFloat, m: Layout.Metrics) -> some View {
        HStack(spacing: 14) {
            Button {
                haptic()
                onClose()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: m.backCorner, style: .continuous)
                        .fill(Color.black.opacity(0.18))

                    RoundedRectangle(cornerRadius: m.backCorner, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Palette.strokeA, Palette.strokeB],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )

                    Image(systemName: "chevron.left")
                        .font(.system(size: m.backIcon, weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 2)
                }
                .frame(width: m.backSize, height: m.backSize)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text("PLAYER PROFILE")
                    .font(.system(size: m.headerTitleSize, weight: .black, design: .rounded))
                    .foregroundColor(Palette.title)
                    .tracking(0.7)

                Text("Stats, progress and avatar")
                    .font(.system(size: m.headerSubtitleSize, weight: .semibold, design: .rounded))
                    .foregroundColor(Palette.bodySoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            Spacer(minLength: 0)

            levelChip(level: profile.level, m: m)
        }
        .padding(.top, max(m.headerTopInset, safeTop + m.headerTopInset))
    }

    private func levelChip(level: Int, m: Layout.Metrics) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.system(size: m.headerSubtitleSize, weight: .black))
                .foregroundColor(Palette.accentYellow)

            Text("LVL \(level)")
                .font(.system(size: m.headerSubtitleSize, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .frame(height: max(30, m.chipHeight - 2))
        .background(
            Capsule(style: .continuous)
                .fill(Palette.chipFill)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Palette.chipStroke, lineWidth: 1)
        )
    }

    private func playerCard(m: Layout.Metrics, isCompact: Bool) -> some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                avatarView(m: m)
                    .frame(width: m.avatarSize, height: m.avatarSize)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Player")
                        .font(.system(size: m.profileTitleSize, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if isCompact {
                        VStack(spacing: 8) {
                            statChip(title: "LEVEL", value: "\(profile.level)", m: m)
                            statChip(title: "XP", value: "\(profile.xpInLevel)/\(profile.xpToNextLevel)", m: m)
                        }
                    } else {
                        HStack(spacing: 10) {
                            statChip(title: "LEVEL", value: "\(profile.level)", m: m)
                            statChip(title: "XP", value: "\(profile.xpInLevel)/\(profile.xpToNextLevel)", m: m)
                        }
                    }
                }

                Spacer(minLength: 0)
            }

            if isCompact {
                VStack(spacing: 10) {
                    actionButton(title: "Choose Avatar", icon: "photo.on.rectangle", m: m) {
                        requestPhotoAccessAndOpenPicker()
                    }
                    actionButton(title: "Remove Avatar", icon: "trash", m: m) {
                        haptic()
                        avatarStore.removeImage()
                    }
                }
            } else {
                HStack(spacing: 10) {
                    actionButton(title: "Choose Avatar", icon: "photo.on.rectangle", m: m) {
                        requestPhotoAccessAndOpenPicker()
                    }
                    actionButton(title: "Remove Avatar", icon: "trash", m: m) {
                        haptic()
                        avatarStore.removeImage()
                    }
                }
                .frame(height: m.actionHeight)
            }
        }
        .padding(m.bigCardPad)
        .background(cardBackground(corner: m.bigCardCorner))
        .overlay(cardStroke(corner: m.bigCardCorner))
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 7)
    }

    private func avatarView(m: Layout.Metrics) -> some View {
        ZStack {
            Circle()
                .fill(Palette.iconBg)

            if let image = avatarStore.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
                Image(Assets.avatarPlaceholder)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .opacity(0.95)
            }
        }
        .overlay(
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Palette.strokeA, Palette.strokeB],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: m.avatarStroke
                )
        )
        .overlay(
            Circle()
                .stroke(Color.white.opacity(glowPulse ? 0.10 : 0.04), lineWidth: 1)
                .blur(radius: glowPulse ? 0 : 0.5)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: glowPulse)
        )
        .shadow(color: Palette.strokeB.opacity(0.18), radius: 12, x: 0, y: 6)
    }

    private func statChip(title: String, value: String, m: Layout.Metrics) -> some View {
        HStack(spacing: m.chipSpacing) {
            Text(title)
                .font(.system(size: m.chipTitleSize, weight: .black, design: .rounded))
                .foregroundColor(Palette.subtitle)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(value)
                .font(.system(size: m.chipValueSize, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
        }
        .padding(.horizontal, m.chipHPad)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: m.chipHeight)
        .background(
            Capsule(style: .continuous)
                .fill(Palette.chipFill)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Palette.chipStroke, lineWidth: 1)
        )
    }

    private func actionButton(title: String, icon: String, m: Layout.Metrics, action: @escaping () -> Void) -> some View {
        Button {
            haptic()
            action()
        } label: {
            HStack(spacing: 9) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.22))
                        .frame(width: m.actionIcon + 18, height: m.actionIcon + 18)

                    Image(systemName: icon)
                        .font(.system(size: m.actionIcon, weight: .bold))
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(.system(size: m.actionFont, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: m.actionHeight)
            .background(
                RoundedRectangle(cornerRadius: m.actionCorner, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "2B0706").opacity(0.98),
                                Color(hex: "1E0505").opacity(0.98)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: m.actionCorner, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func resetProgressButton(m: Layout.Metrics) -> some View {
        Button {
            haptic()
            showResetConfirm = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: m.actionIcon, weight: .black))
                    .foregroundColor(.white)

                Text("Reset Progress")
                    .font(.system(size: m.actionFont, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: m.actionHeight)
            .background(
                RoundedRectangle(cornerRadius: m.actionCorner, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "7A0B0B").opacity(0.95),
                                Color(hex: "3A0606").opacity(0.95)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: m.actionCorner, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 7)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func statsGrid(m: Layout.Metrics) -> some View {
        let columns: [GridItem] = [
            GridItem(.flexible(), spacing: m.gridSpacing, alignment: .top),
            GridItem(.flexible(), spacing: m.gridSpacing, alignment: .top)
        ]

        return LazyVGrid(columns: columns, spacing: m.gridSpacing) {
            statCard(
                icon: "sparkles",
                iconTint: Palette.accentYellow,
                value: "\(ProfileMetaStorage.shared.appOpenCount)",
                title: "App Opens",
                subtitle: "Total launches",
                m: m
            )

            statCard(
                icon: "arrow.triangle.2.circlepath",
                iconTint: Palette.accentYellow,
                value: "\(profile.totalSpins)",
                title: "Total Spins",
                subtitle: "All spins combined",
                m: m
            )

            statCard(
                icon: "trophy.fill",
                iconTint: Palette.accentGreen,
                value: "\(achievementsCompleted)/\(AchievementDefinitions.all.count)",
                title: "Achievements",
                subtitle: "Completed",
                m: m
            )

            statCard(
                icon: "checkmark.seal.fill",
                iconTint: Palette.accentOrange,
                value: "\(questsCompleted)/\(QuestDefinitions.all.count)",
                title: "Quests",
                subtitle: "Completed",
                m: m
            )

            statCard(
                icon: "arrow.up.right.circle.fill",
                iconTint: Palette.accentGreen,
                value: formatted(profile.totalWon),
                title: "Won",
                subtitle: "Total winnings",
                m: m
            )

            statCard(
                icon: "arrow.down.right.circle.fill",
                iconTint: Palette.accentRed,
                value: formatted(profile.totalLost),
                title: "Lost",
                subtitle: "Total losses",
                m: m
            )
        }
    }

    private func statCard(
        icon: String,
        iconTint: Color,
        value: String,
        title: String,
        subtitle: String,
        m: Layout.Metrics
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Palette.iconBg)
                        .frame(width: 36, height: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        )

                    Image(systemName: icon)
                        .font(.system(size: m.statIconSize, weight: .black))
                        .foregroundColor(iconTint)
                }

                Spacer(minLength: 0)
            }

            Spacer().frame(height: 12)

            Text(value)
                .font(.system(size: m.statValueSize, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.66)
                .frame(height: 30, alignment: .leading)

            Spacer().frame(height: 8)

            Text(title)
                .font(.system(size: m.statTitleSize, weight: .black, design: .rounded))
                .foregroundColor(Palette.subtitle)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(height: 22, alignment: .leading)

            Spacer().frame(height: 6)

            Text(subtitle)
                .font(.system(size: m.statSubtitleSize, weight: .semibold, design: .rounded))
                .foregroundColor(Palette.bodySoft)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 30, alignment: .topLeading)

            Spacer(minLength: 0)
        }
        .padding(m.bigCardPad)
        .frame(maxWidth: .infinity, minHeight: m.statCardHeight, maxHeight: m.statCardHeight, alignment: .topLeading)
        .background(cardBackground(corner: m.bigCardCorner))
        .overlay(cardStroke(corner: m.bigCardCorner))
    }

    private func progressCard(m: Layout.Metrics) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Progress")
                    .font(.system(size: m.profileTitleSize - 2, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Spacer(minLength: 0)

                Text("Keep going")
                    .font(.system(size: max(12, m.progressCaptionSize), weight: .bold, design: .rounded))
                    .foregroundColor(Palette.bodySoft)
            }

            VStack(spacing: 12) {
                progressRow(
                    title: "Level",
                    percentText: "\(Int((levelProgress * 100).rounded()))%",
                    progress: levelProgress,
                    leftCaption: "\(profile.xpInLevel) XP",
                    rightCaption: "\(profile.xpToNextLevel) XP",
                    m: m
                )

                progressRow(
                    title: "Achievements",
                    percentText: "\(Int((achievementProgress * 100).rounded()))%",
                    progress: achievementProgress,
                    leftCaption: "\(achievementsCompleted)",
                    rightCaption: "\(AchievementDefinitions.all.count)",
                    m: m
                )

                progressRow(
                    title: "Quests",
                    percentText: "\(Int((questProgress * 100).rounded()))%",
                    progress: questProgress,
                    leftCaption: "\(questsCompleted)",
                    rightCaption: "\(QuestDefinitions.all.count)",
                    m: m
                )
            }
        }
        .padding(m.bigCardPad)
        .background(cardBackground(corner: m.progressOuterCorner))
        .overlay(cardStroke(corner: m.progressOuterCorner))
    }

    private func progressRow(
        title: String,
        percentText: String,
        progress: CGFloat,
        leftCaption: String,
        rightCaption: String,
        m: Layout.Metrics
    ) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: m.progressTitleSize, weight: .black, design: .rounded))
                    .foregroundColor(Palette.subtitle)

                Spacer()

                Text(percentText)
                    .font(.system(size: m.progressPercentSize, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Palette.trackFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(Palette.trackStroke, lineWidth: 1)
                    )
                    .frame(height: 18)

                GeometryReader { gp in
                    let clamped = max(0, min(progress, 1))
                    let w = gp.size.width * clamped

                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFE3A0"),
                                    Color(hex: "F2B35A"),
                                    Color(hex: "D88235")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(w > 0 ? 10 : 0, w), height: 18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                }
                .frame(height: 18)
            }
            .frame(height: 18)

            HStack {
                Text(leftCaption)
                Spacer()
                Text(rightCaption)
            }
            .font(.system(size: m.progressCaptionSize, weight: .bold, design: .rounded))
            .foregroundColor(Color.white.opacity(0.82))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: m.progressRowHeight, maxHeight: m.progressRowHeight, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: m.progressInnerCorner, style: .continuous)
                .fill(Palette.cardFillSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: m.progressInnerCorner, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func cardBackground(corner: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Palette.cardFill,
                        Palette.cardFillSoft
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private func cardStroke(corner: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [Palette.strokeA, Palette.strokeB, Color.white.opacity(0.06)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.6
            )
    }

    private var achievementsCompleted: Int {
        AchievementDefinitions.all.reduce(into: 0) { result, def in
            let current = profile.achievementProgressValue(for: def.id)
            let completed = current >= def.target || profile.isClaimed(.achievement, id: def.id)
            if completed { result += 1 }
        }
    }

    private var questsCompleted: Int {
        QuestDefinitions.all.reduce(into: 0) { result, def in
            let current = profile.questProgressValue(for: def.id)
            let completed = current >= def.target || profile.isClaimed(.quest, id: def.id)
            if completed { result += 1 }
        }
    }

    private var levelProgress: CGFloat {
        guard profile.xpToNextLevel > 0 else { return 0 }
        return CGFloat(profile.xpInLevel) / CGFloat(profile.xpToNextLevel)
    }

    private var achievementProgress: CGFloat {
        let total = max(1, AchievementDefinitions.all.count)
        return CGFloat(achievementsCompleted) / CGFloat(total)
    }

    private var questProgress: CGFloat {
        let total = max(1, QuestDefinitions.all.count)
        return CGFloat(questsCompleted) / CGFloat(total)
    }

    private func formatted(_ value: Int) -> String {
        ProfileNumberFormatter.shared.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func requestPhotoAccessAndOpenPicker() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            isAvatarPickerPresented = true

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                Task { @MainActor in
                    switch newStatus {
                    case .authorized, .limited:
                        isAvatarPickerPresented = true
                    default:
                        showPhotoAccessDeniedAlert = true
                    }
                }
            }

        case .denied, .restricted:
            showPhotoAccessDeniedAlert = true

        @unknown default:
            showPhotoAccessDeniedAlert = true
        }
    }

    private func haptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

private enum ProfileNumberFormatter {
    static let shared: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        return f
    }()
}

final class ProfileMetaStorage {
    static let shared = ProfileMetaStorage()

    private let appOpenCountKey = "projectx.profile.meta.appOpenCount.v1"

    var appOpenCount: Int {
        UserDefaults.standard.integer(forKey: appOpenCountKey)
    }

    func registerAppOpen() {
        let next = appOpenCount + 1
        UserDefaults.standard.set(next, forKey: appOpenCountKey)
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: appOpenCountKey)
    }
}

private struct ProfileImagePicker: UIViewControllerRepresentable {
    let onPick: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current

        let vc = PHPickerViewController(configuration: config)
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onPick: (UIImage?) -> Void

        init(onPick: @escaping (UIImage?) -> Void) {
            self.onPick = onPick
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else {
                onPick(nil)
                return
            }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { object, _ in
                    let image = object as? UIImage
                    Task { @MainActor in
                        self.onPick(image)
                    }
                }
            } else {
                onPick(nil)
            }
        }
    }
}

private extension UIImage {
    func profilePreparedAvatar(targetSide: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: targetSide, height: targetSide))
        return renderer.image { _ in
            let square = min(size.width, size.height)
            let crop = CGRect(
                x: (size.width - square) / 2,
                y: (size.height - square) / 2,
                width: square,
                height: square
            )

            if let cg = cgImage?.cropping(to: crop) {
                UIImage(cgImage: cg, scale: scale, orientation: imageOrientation)
                    .draw(in: CGRect(x: 0, y: 0, width: targetSide, height: targetSide))
            } else {
                draw(in: CGRect(x: 0, y: 0, width: targetSide, height: targetSide))
            }
        }
    }
}

private struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
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
            opacity: 1
        )
    }
}
