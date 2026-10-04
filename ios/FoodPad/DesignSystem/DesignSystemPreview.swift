//
//  DesignSystemPreview.swift
//  FoodPad
//
//  Écran de référence : affiche tous les tokens du design system d'un coup.
//
//  Sert de garde-fou — quand une valeur change, cet écran montre immédiatement
//  l'effet sur l'ensemble de la palette et de la typo.
//

import SwiftUI

struct DesignSystemPreview: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                colorsSection
                typographySection
                spacingSection
                shapesSection
                footer
            }
            .padding(20)
        }
        .background(Color.white)
        .navigationTitle("Design System")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - En-tête

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FoodPad")
                .font(.system(size: 32, weight: .heavy))
                .foregroundStyle(Theme.neutral800)

            Text("Design system — phase 1")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.neutral500)

            // Dimensions réelles de l'écran : utile pour vérifier que
            // les valeurs hp() / wp() se comportent comme prévu.
            HStack(spacing: 8) {
                metric("largeur", "\(Int(ScreenMetrics.screenWidth)) pt")
                metric("hauteur", "\(Int(ScreenMetrics.screenHeight)) pt")
                metric("5.hp()", String(format: "%.1f", 5.hp()))
                metric("45.hp()", String(format: "%.1f", 45.hp()))
            }
        }
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.neutral800)
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Theme.cardPlaceholder, in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Couleurs

    private var colorsSection: some View {
        section("Couleurs", note: "Palette de référence") {
            VStack(spacing: 10) {
                ColorSwatch(name: "accent", hex: "f64e32", color: Theme.accent)
                ColorSwatch(name: "neutral-800", hex: "262626", color: Theme.neutral800)
                ColorSwatch(name: "neutral-700", hex: "404040", color: Theme.neutral700)
                ColorSwatch(name: "neutral-600", hex: "525252", color: Theme.neutral600)
                ColorSwatch(name: "neutral-500", hex: "737373", color: Theme.neutral500)
                ColorSwatch(name: "pillInactive", hex: "000000 / 10%", color: Theme.pillInactive)
                ColorSwatch(name: "cardPlaceholder", hex: "000000 / 5%", color: Theme.cardPlaceholder)
            }
        }
    }

    // MARK: - Typographie

    private var typographySection: some View {
        section("Typographie", note: "San Francisco — aucune police embarquée") {
            VStack(spacing: 14) {
                TypeSample(label: "welcomeTitle · heavy · 5.hp()", sample: "FoodPad",
                           font: Typo.welcomeTitle, tracking: Typo.welcomeTracking)
                TypeSample(label: "welcomeSubtitle · medium · 2.5.hp()", sample: "Explore some delicious Food",
                           font: Typo.welcomeSubtitle, tracking: Typo.subtitleTracking)
                TypeSample(label: "homeHeadline · bold · 3.5.hp()", sample: "Fast & Delicious",
                           font: Typo.homeHeadline)
                TypeSample(label: "homeHeadlineAccent · heavy · 3.5.hp()", sample: "Food You Love",
                           font: Typo.homeHeadlineAccent)
                TypeSample(label: "searchPlaceholder · regular · 1.7.hp()", sample: "Search Your Favorite Food",
                           font: Typo.searchPlaceholder, color: Theme.neutral500, tracking: Typo.searchTracking)
                TypeSample(label: "categoryLabel · regular · 1.6.hp()", sample: "Seafood",
                           font: Typo.categoryLabel)
                TypeSample(label: "recipesCount · semibold · 2.hp()", sample: "14 Recipes",
                           font: Typo.recipesCount, color: Theme.neutral600)
                TypeSample(label: "recipeCardTitle · semibold · 2.2.hp()", sample: "Spicy Arrabiata",
                           font: Typo.recipeCardTitle, color: .white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Theme.cardGradientBottom, in: RoundedRectangle(cornerRadius: 10))
                TypeSample(label: "detailMealName · bold · 3.hp()", sample: "Spicy Arrabiata",
                           font: Typo.detailMealName, color: Theme.neutral700)
                TypeSample(label: "detailArea · medium · 2.hp()", sample: "Italian",
                           font: Typo.detailArea, color: Theme.neutral500)
                TypeSample(label: "detailSectionTitle · bold · 2.5.hp()", sample: "Ingredients",
                           font: Typo.detailSectionTitle, color: Theme.neutral700)
                TypeSample(label: "ingredientName · medium · 1.7.hp()",
                           sample: "Pasta  ·  200g", font: Typo.ingredientName, color: Theme.neutral800)
                TypeSample(label: "instructions · regular · 1.7.hp()",
                           sample: "Bring a large pot of water to a boil…", font: Typo.instructions,
                           color: Theme.neutral700)
            }
        }
    }

    // MARK: - Échelle hp()

    private var spacingSection: some View {
        section("Échelle hp()", note: "1.hp() = 1 % de la hauteur d'écran") {
            VStack(alignment: .leading, spacing: 6) {
                ForEach([1.5, 1.7, 2.2, 2.5, 3.5, 5.0], id: \.self) { value in
                    HStack(spacing: 10) {
                        Text("\(value, specifier: "%.1f").hp()")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(Theme.accent)
                            .frame(width: 56, alignment: .leading)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Theme.neutral800.opacity(0.75))
                            .frame(width: value.hp(), height: 8)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    // MARK: - Formes

    private var shapesSection: some View {
        section("Formes", note: "rayons relevés sur la maquette") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    shape("35 pt", value: 35, note: "carte recette")
                    shape("50 pt", value: 50, note: "haut de la fiche")
                    shape("12 pt", value: 12, note: "rounded-xl")
                    shape("6 pt", value: 6, note: "pastille cat.")
                }
                HStack(spacing: 10) {
                    shape("1.5.hp()", value: 1.5.hp(), note: "point ingrédient")
                    shape("5.hp()", value: 5.hp(), note: "avatar")
                    shape("6.hp()", value: 6.hp(), note: "miniature cat.")
                    shape("6.hp()", value: 6.hp(), note: "loupe")
                }
            }
        }
    }

    private func shape(_ title: String, value: CGFloat, note: String) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: min(value, 22), style: .continuous)
                .fill(Theme.accent.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: min(value, 22), style: .continuous)
                        .strokeBorder(Theme.accent.opacity(0.5), lineWidth: 1)
                )
                .frame(width: 66, height: 44)
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
            Text(note)
                .font(.system(size: 8))
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Pied

    private var footer: some View {
        Text("""
        Ces valeurs sont celles de la palette Tailwind v3 par défaut. \
        Si le rendu diffère de la maquette, c'est que l'une des hypothèses \
        ci-dessus est fausse — notamment si le thème a été surchargé.
        """)
        .font(.system(size: 11))
        .foregroundStyle(.tertiary)
        .padding(.top, 8)
    }

    // MARK: - Gabarit

    @ViewBuilder
    private func section<Content: View>(
        _ title: String,
        note: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.neutral800)
                Text(note)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            content()
        }
    }
}

#Preview("Design System") {
    DesignSystemPreview()
}
