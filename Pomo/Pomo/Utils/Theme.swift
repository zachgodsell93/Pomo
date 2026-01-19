import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct Theme {
    // Light mode colors
    static let darkBlue = Color(hex: "#03045e")
    static let mediumBlue = Color(hex: "#0077b6")
    static let lightBlue = Color(hex: "#00b4d8")
    static let paleBlue = Color(hex: "#90e0ef")
    static let veryPaleBlue = Color(hex: "#caf0f8")

    // Dark mode colors
    static let darkGrey = Color(hex: "#2d2d2d")
    static let brightBlue = Color(hex: "#4da6ff")
    static let brighterBlue = Color(hex: "#66c2ff")

    // Semantic aliases - computed based on dark mode setting
    static var background: Color {
        SettingsManager.shared.darkMode ? darkGrey : veryPaleBlue
    }

    static var timerText: Color {
        SettingsManager.shared.darkMode ? .white : darkBlue
    }

    static var accent: Color {
        SettingsManager.shared.darkMode ? brightBlue : mediumBlue
    }

    static var secondaryAccent: Color {
        SettingsManager.shared.darkMode ? brighterBlue : lightBlue
    }
}
