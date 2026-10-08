//
//  RecipeCard.swift
//  FoodPad
//
//  Carte d'une recette dans la grille en maçonnerie.
//
//  Règles de mise en page :
//
//    - marge interne alternée (index pair → 8 pt), pour décaler les colonnes
//    - hauteur : 25 % de l'écran si `index % 3 == 0`, sinon 35 %
//    - coins à 35
//    - dégradé transparent → noir 90 %, sur les 20 % inférieurs
//    - titre tronqué à 20 caractères, « ... » au-delà
//

import SwiftUI

struct RecipeCard: View {

    let meal: Meal
    let index: Int
    var onTap: () -> Void

    /// Marge à droite appliquée aux cartes d'indice pair, pour créer
    /// l'escalier irrégulier caractéristique de l'app d'origine.
    private var trailingInset: CGFloat { index % 2 == 0 ? 8 : 0 }

    /// Hauteur imposée par la règle de l'app d'origine.
    private var height: CGFloat { MasonryGrid.cardHeights(index) }

    var body: some View {
        // Le `Layout` propose la largeur de colonne ; on la récupère ici pour
        // pouvoir déduire la largeur réelle de la carte.
        GeometryReader { geo in
            card(width: geo.size.width)
        }
        .frame(height: height)
    }

    private func card(width: CGFloat) -> some View {
        let cardWidth = max(0, width - trailingInset)

        return ZStack(alignment: .topLeading) {
            // Image de fond
            CachedImage(url: meal.thumbnailURL) { image in
                image
            } placeholder: {
                Theme.cardPlaceholder
            }
            .frame(width: cardWidth, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 35, style: .continuous))

            // Dégradé sur le tiers inférieur
            Theme.cardGradient
                .frame(width: cardWidth, height: 20.hp())
                .frame(maxHeight: .infinity, alignment: .bottom)
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: 35,
                        bottomTrailingRadius: 35,
                        style: .continuous
                    )
                )
                .allowsHitTesting(false)

            // Titre, en bas à gauche, largeur plafonnée à 80 %
            Text(truncatedTitle)
                .font(Typo.recipeCardTitle)
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(width: cardWidth * 0.8, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.leading, 8)
                .padding(.bottom, 28)
                .allowsHitTesting(false)
        }
        .frame(width: width, height: height, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(meal.name)
        .accessibilityAddTraits(.isButton)
    }

    /// Troncature à 20 caractères, comme dans l'app d'origine.
    ///
    /// Ce n'est **pas** un `lineLimit` : le texte est coupé au caractère 20 et
    /// complété de « … », même s'il tiendrait sur une ligne.
    private var truncatedTitle: String {
        meal.name.count > 20 ? String(meal.name.prefix(20)) + "…" : meal.name
    }
}

// MARK: - Grille complète

/// La grille complète : en-tête « N Recipes » + maçonnerie.
struct RecipesGrid: View {

    let meals: [Meal]
    var isSearching: Bool = false
    var onSelect: (Meal) -> Void

    /// Espacement vertical entre deux cartes d'une même colonne.
    private let spacing: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !isSearching {
                RecipesHeader(count: meals.count)
            }

            if meals.isEmpty {
                Loading(topPadding: 80)
                    .frame(height: 40.hp())
            } else {
                MasonryGrid(
                    columns: 2,
                    verticalSpacing: spacing,
                    heightForIndex: MasonryGrid.cardHeights
                ) {
                    ForEach(Array(meals.enumerated()), id: \.element.id) { index, meal in
                        RecipeCard(meal: meal, index: index) {
                            onSelect(meal)
                        }
                    }
                }
                .frame(height: gridHeight)
            }
        }
    }

    /// Le protocole `Layout` ne communique pas sa hauteur à la vue parente.
    ///
    /// On la calcule donc ici, en simulant le placement (colonne la plus
    /// courte). Les hauteurs étant fixes, cette simulation est **indépendante
    /// de la largeur** — c'est pourquoi un calcul direct suffit.
    private var gridHeight: CGFloat {
        guard !meals.isEmpty else { return 0 }
        var heights = [CGFloat.zero, CGFloat.zero]

        for index in meals.indices {
            let slot = heights[0] <= heights[1] ? 0 : 1
            heights[slot] += MasonryGrid.cardHeights(index) + spacing
        }

        return max(0, (heights.max() ?? 0) - spacing)
    }
}
