//
//  Color+Hex.swift
//  FoodPad
//
//  Initialiseur de couleur depuis une chaîne hexadécimale.
//  Les valeurs utilisées dans l'app sont récapitulées dans `Theme.swift`.
//

import SwiftUI

extension Color {

    /// Construit une couleur depuis un hex, avec ou sans `#`.
    ///
    ///     Color(hex: "f64e32")
    ///     Color(hex: "000000", opacity: 0.9)
    ///
    /// - Returns: La couleur, ou `.clear` si la chaîne est invalide.
    init(hex: String, opacity: Double = 1) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        }

        guard cleaned.count == 6,
              let value = UInt64(cleaned, radix: 16) else {
            assertionFailure("Couleur hexadécimale invalide : \(hex)")
            self = .clear
            return
        }

        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: opacity
        )
    }

    /// Compose une couleur au-dessus d'une autre : un noir à 10 % d'opacité
    /// au-dessus d'un fond clair.
    static func overlay(_ color: Color, opacity: Double) -> Color {
        color.opacity(opacity)
    }
}
