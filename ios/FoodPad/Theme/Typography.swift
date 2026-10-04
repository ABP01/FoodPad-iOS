//
//  Typography.swift
//  FoodPad
//
//  Équivalent Swift des `className` Tailwind de l'app React Native.
//
//  L'app d'origine n'embarque aucune police : elle utilise la police système
//  (San Francisco sur iOS) et ne fait varier que la **graisse** et la **taille**.
//  Traduction : `Font.system(size:weight:)`.
//
//  Correspondance des graisses Tailwind → SwiftUI :
//
//      font-medium   → .medium
//      font-semibold → .semibold
//      font-bold     → .bold
//      font-extrabold→ .heavy
//
//  Toutes les tailles sont exprimées via `hp()` (voir Responsive.swift).
//

import SwiftUI

enum Typo {

    // MARK: - Welcome

    /// `font-extrabold` + `hp(5)` + `tracking-widest` — « FoodPad »
    static var welcomeTitle: Font {
        .system(size: 5.hp(), weight: .heavy)
    }

    /// `font-medium` + `hp(2.5)` + `tracking-widest` — « Explore some delicious Food »
    static var welcomeSubtitle: Font {
        .system(size: 2.5.hp(), weight: .medium)
    }

    /// `font-medium` + `hp(2.2)` — libellé du bouton « Get Started »
    static var welcomeButton: Font {
        .system(size: 2.2.hp(), weight: .medium)
    }

    // MARK: - Home

    /// `font-bold` + `hp(3.5)` — « Fast & Delicious »
    static var homeHeadline: Font {
        .system(size: 3.5.hp(), weight: .bold)
    }

    /// `font-extrabold` + `hp(3.5)` — « Food You **Love** »
    static var homeHeadlineAccent: Font {
        .system(size: 3.5.hp(), weight: .heavy)
    }

    /// `hp(1.7)` — placeholder de la barre de recherche
    static var searchPlaceholder: Font {
        .system(size: 1.7.hp(), weight: .regular)
    }

    /// `hp(1.6)` — nom sous chaque catégorie
    static var categoryLabel: Font {
        .system(size: 1.6.hp(), weight: .regular)
    }

    /// `font-semibold` + `hp(2)` — « 14 Recipes »
    static var recipesCount: Font {
        .system(size: 2.hp(), weight: .semibold)
    }

    // MARK: - Carte de recette

    /// `font-semibold` + `hp(2.2)` — nom du plat sur la carte
    static var recipeCardTitle: Font {
        .system(size: 2.2.hp(), weight: .semibold)
    }

    // MARK: - Détails

    /// `font-bold` + `hp(3)` — nom du plat
    static var detailMealName: Font {
        .system(size: 3.hp(), weight: .bold)
    }

    /// `font-medium` + `hp(2)` — origine du plat
    static var detailArea: Font {
        .system(size: 2.hp(), weight: .medium)
    }

    /// `font-bold` + `hp(2.5)` — « Ingredients » / « Instructions »
    static var detailSectionTitle: Font {
        .system(size: 2.5.hp(), weight: .bold)
    }

    /// `font-medium` + `hp(1.7)` — nom d'un ingrédient
    static var ingredientName: Font {
        .system(size: 1.7.hp(), weight: .medium)
    }

    /// `font-extrabold` + `hp(1.7)` — quantité d'un ingrédient
    static var ingredientMeasure: Font {
        .system(size: 1.7.hp(), weight: .heavy)
    }

    /// `hp(1.7)` — corps des instructions
    static var instructions: Font {
        .system(size: 1.7.hp(), weight: .regular)
    }

    // MARK: - Espacement des lettres

    /// `tracking-widest` — appliqué aux titres de l'écran Welcome.
    static let welcomeTracking: CGFloat = 4
    /// `tracking-widest` — appliqué au sous-titre.
    static let subtitleTracking: CGFloat = 2
    /// `tracking-widest` — appliqué au placeholder de recherche.
    static let searchTracking: CGFloat = 2
}

// MARK: - Rendu d'une ligne

/// Aperçu d'un style typographique : échantillon + valeur relevée sur le RN.
struct TypeSample: View {
    let label: String
    let sample: String
    let font: Font
    var color: Color = Theme.neutral800
    var tracking: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(sample)
                .font(font)
                .tracking(tracking)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(label)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
