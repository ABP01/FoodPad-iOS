//
//  MasonryGrid.swift
//  FoodPad
//
//  Grille en maçonnerie à 2 colonnes.
//
//  Implémentée comme un `Layout` SwiftUI natif (iOS 16+), plutôt qu'un paquet
//  SPM tiers, pour garder le contrôle total sur la règle de placement.
//
//  Chaque élément est placé dans **la colonne la plus courte**. Les colonnes
//  démarrent à la même hauteur en haut, contrairement à un `VStack` de
//  `HStack` qui produirait des colonnes mal alignées.
//

import SwiftUI

// MARK: - Layout

struct MasonryGrid: Layout {

    /// Nombre de colonnes.
    var columns: Int = 2

    /// Espace vertical entre deux cartes d'une même colonne.
    var verticalSpacing: CGFloat = 0

    /// Hauteur d'une carte, selon son index dans la liste.
    ///
    /// Cette hauteur **ne dépend pas de la longueur du nom** : c'est une
    /// convention graphique arbitraire de l'app d'origine, reproduite ici pour
    /// garantir l'identité visuelle. C'est aussi le premier endroit où le
    /// design pourra être amélioré dans la version native.
    var heightForIndex: (Int) -> CGFloat

    /// Gaps accumulés en fin de placement, réutilisés pour `sizeThatFits`
    /// sans refaire un deuxième parcours.
    ///
    /// - Note: Doit être au moins `internal` : `makeCache(subviews:)` est une
    ///   exigence du protocole `Layout`, donc le type de retour ne peut pas
    ///   être plus restrictif que le type lui-même.
    struct Cache {
        var columnHeights: [CGFloat] = []
        var maxHeight: CGFloat = 0
    }

    // MARK: Layout

    func makeCache(subviews: Subviews) -> Cache {
        Cache()
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let width = proposal.width ?? 0
        guard width > 0, columns > 0 else {
            return .zero
        }

        var heights = Array(repeating: CGFloat.zero, count: columns)

        for index in mealsCount(subviews) {
            let slot = Self.shortestColumn(in: heights)
            heights[slot] += heightForIndex(index) + verticalSpacing
        }

        // On retire l'espacement du dernier élément de chaque colonne.
        let maxHeight = heights.isEmpty ? 0 : (heights.max() ?? 0) - verticalSpacing

        cache.columnHeights = heights
        cache.maxHeight = maxHeight

        return CGSize(width: width, height: max(0, maxHeight))
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        guard columns > 0 else { return }

        let columnWidth = Self.columnWidth(in: bounds.width, columns: columns)
        var heights = Array(repeating: CGFloat.zero, count: columns)

        for (index, subview) in subviews.enumerated() {
            let slot = Self.shortestColumn(in: heights)
            let height = heightForIndex(index)

            let x = bounds.minX + CGFloat(slot) * columnWidth
            let y = bounds.minY + heights[slot]

            subview.place(
                at: CGPoint(x: x, y: y),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: columnWidth, height: height)
            )

            heights[slot] += height + verticalSpacing
        }

        cache.columnHeights = heights
        cache.maxHeight = heights.isEmpty ? 0 : (heights.max() ?? 0) - verticalSpacing
    }

    // MARK: - Helpers

    /// Bornes des indices des sous-vues, sans matérialiser le tableau.
    private func mealsCount(_ subviews: Subviews) -> Range<Int> {
        0..<subviews.count
    }

    private static func columnWidth(in width: CGFloat, columns: Int) -> CGFloat {
        width / CGFloat(max(1, columns))
    }

    /// Index de la colonne la plus basse. À égalité, la colonne de gauche
    /// gagne — c'est ce qui produit l'alternance gauche/droite de l'app
    /// d'origine.
    private static func shortestColumn(in heights: [CGFloat]) -> Int {
        var shortest = 0
        for (index, height) in heights.enumerated() where height < heights[shortest] {
            shortest = index
        }
        return shortest
    }
}

// MARK: - Règle de hauteur des cartes

extension MasonryGrid {

    /// Une carte sur 3 est « courte » (25 % de la hauteur d'écran),
    /// les deux autres sont « longues » (35 %). L'alternance casse
    /// l'alignement vertical des deux colonnes.
    static let cardHeights: (Int) -> CGFloat = { index in
        index % 3 == 0 ? 25.hp() : 35.hp()
    }
}
