// Path: Shared/Color+Hex.swift

import SwiftUI

extension Color {
    init(hex: String, alpha: Double = 1) {
        let sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)

        let r, g, b: Double
        if sanitized.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        } else {
            r = 1; g = 1; b = 1
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
