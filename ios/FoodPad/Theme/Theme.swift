//
//  Theme.swift
//  FoodPad
//
//  Palette de couleurs de l'app.
//
//  ⚠️  Les gris suivent la palette Tailwind v3 (`neutral-500`…`neutral-800`),
//  relevés sur la maquette d'origine. Vérifie le rendu réel si tu surcharges un
//  jour le thème.
//

import SwiftUI

enum Theme {

    // MARK: - Couleur d'accent

    /// `#f64e32` — fond de l'écran Welcome, catégorie active, cœur favori,
    /// points de la liste d'ingrédients, texte du bouton principal.
    static let accent = Color(hex: "f64e32")

    /// Dégradé du bas de carte : `rgba(0,0,0,0.9)`.
    static let cardGradientBottom = Color(hex: "000000", opacity: 0.9)
    /// Dégradé du haut de carte : `transparent`.
    static let cardGradientTop = Color.clear

    // MARK: - Gris de texte

    /// `neutral-500` — origine du plat sur l'écran de détails.
    static let neutral500 = Color(hex: "737373")
    /// `neutral-600` — compteur de recettes (« 14 Recipes »).
    static let neutral600 = Color(hex: "525252")
    /// `neutral-700` — nom du plat, titres de section, instructions.
    static let neutral700 = Color(hex: "404040")
    /// `neutral-800` — titres de l'accueil, noms de catégories.
    static let neutral800 = Color(hex: "262626")

    // MARK: - Fonds

    /// `bg-black/10` — catégorie non sélectionnée.
    static let pillInactive = Color.black.opacity(0.1)
    /// `bg-black/5` — fond d'image pendant le chargement.
    static let cardPlaceholder = Color.black.opacity(0.05)

    // MARK: - Gradients

    /// Dégradé vertical des cartes de recettes :
    /// `["transparent", "rgba(0,0,0,0.9)"]` de haut en bas.
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [cardGradientTop, cardGradientBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Rendu d'une ligne

/// Aperçu visuel d'une couleur : swatch + nom + hex.
struct ColorSwatch: View {
    let name: String
    let hex: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color)
                .frame(width: 52, height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(.black.opacity(0.12), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 13, weight: .semibold))
                Text("#\(hex)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }
}
