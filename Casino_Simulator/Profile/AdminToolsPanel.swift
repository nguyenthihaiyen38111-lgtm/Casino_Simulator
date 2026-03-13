// Path: Profile/AdminToolsPanel.swift

import SwiftUI
import UIKit

struct AdminToolsPanel: View {
    @ObservedObject var adminAccess: AdminToolsAccess

    let onUnlockAllGames: () -> Void
    let onResetTestingUnlocks: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var showResetAlert = false

    private enum Palette {
        static let background = Color(hex: "140507")
        static let card = Color(hex: "3A0D15")
        static let inner = Color(hex: "2A0810")
        static let gold = Color(hex: "E0B35A")
        static let goldSoft = Color(hex: "FFF0C8")
        static let text = Color(hex: "FFF4DD")
        static let textDim = Color.white.opacity(0.72)
        static let danger = Color(hex: "B63A46")
        static let success = Color(hex: "C49A43")
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
        ZStack {
            Palette.background
                .ignoresSafeArea()

            VStack(spacing: 18) {
                header
                unlockCard
                accessCard
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
        }
        .alert("Reset testing unlocks?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                adminAccess.setUnlockAllGames(false)
                onResetTestingUnlocks()
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Admin Tools")
                    .font(Typography.font(size: 28))
                    .foregroundColor(Palette.text)

                Text("Local testing controls")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Palette.textDim)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Palette.card)

                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Palette.gold, Palette.goldSoft],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )

                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(Palette.text)
                }
                .frame(width: 42, height: 42)
            }
            .buttonStyle(.plain)
        }
    }

    private var unlockCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Game Access")
                .font(Typography.font(size: 22))
                .foregroundColor(Palette.text)

            Text("Enable local testing override and make all game modes available for quick checking.")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(Palette.textDim)
                .fixedSize(horizontal: false, vertical: true)

            Toggle(
                isOn: Binding(
                    get: { adminAccess.isAllGamesUnlockedForTesting },
                    set: { newValue in
                        adminAccess.setUnlockAllGames(newValue)

                        if newValue {
                            onUnlockAllGames()
                        } else {
                            showResetAlert = true
                        }
                    }
                )
            ) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock all games")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Palette.text)

                    Text(adminAccess.isAllGamesUnlockedForTesting ? "All modes available" : "Uses normal progression")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Palette.textDim)
                }
            }
            .tint(Palette.success)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Palette.gold, Palette.goldSoft],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
    }

    private var accessCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Panel Access")
                .font(Typography.font(size: 22))
                .foregroundColor(Palette.text)

            Text("Disable the hidden admin tools after testing is finished.")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(Palette.textDim)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                adminAccess.disablePanel()
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Palette.inner)

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Palette.danger, Palette.goldSoft],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )

                    Text("Disable Admin Panel")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Palette.text)
                }
                .frame(height: 52)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Palette.gold, Palette.goldSoft],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
    }
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
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}
