//
//  FilterSheet.swift
//  FoodPad
//
//  Feuille de filtres, ouverte depuis l'icône d'ajustement de l'accueil.
//
//  ⚠️  Cette icône est **décorative** dans l'app React Native d'origine
//  (`HomeScreen.js` ne lui attache aucun `onPress`). La transformer en vrai
//  contrôleur est donc un ajout, pas une restauration — cf. MIGRATION_SWIFT.md
//  § 5.2.
//
//  Deux critères : une catégorie (comme la barre de catégories du dessus) et un
//  interrupteur « favoris uniquement ».
//

import SwiftUI

// MARK: - Filtre

/// Critères de filtrage de la grille.
struct RecipeFilter: Equatable {

    /// `nil` = toutes les catégories.
    var category: String?

    /// Ne montrer que les platsAjoutés aux favoris.
    var favoritesOnly: Bool = false

    /// Vrai si le filtre restreint la liste par rapport à « tout afficher ».
    var isRestricting: Bool { category != nil || favoritesOnly }

    /// Résumé court pour l'info-bulle de l'icône d'ajustement.
    var summary: String {
        var parts: [String] = []
        if let category { parts.append(category) }
        if favoritesOnly { parts.append("Favoris") }
        return parts.isEmpty ? "Aucune sélection" : parts.joined(separator: " · ")
    }

    /// Libellé de la catégorie retenue, ou celui par défaut de l'app.
    var resolvedCategory: String {
        category ?? LiveMealService.defaultCategory
    }
}

// MARK: - Feuille

struct FilterSheet: View {

    let categories: [Category]
    let favoritesCount: Int
    let onApply: (RecipeFilter) -> Void

    @Environment(\.dismiss) private var dismiss

    /// Copie de travail : rien n'est appliqué tant que l'utilisateur n'a pas
    /// validé, ce qui permet d'annuler sans déclencher d'appel réseau.
    @State private var draft: RecipeFilter

    init(
        categories: [Category],
        favoritesCount: Int,
        filter: RecipeFilter,
        onApply: @escaping (RecipeFilter) -> Void
    ) {
        self.categories = categories
        self.favoritesCount = favoritesCount
        self.onApply = onApply
        _draft = State(initialValue: filter)
    }

    var body: some View {
        NavigationStack {
            Form {
                categorySection
                displaySection
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply(draft)
                        dismiss()
                    }
                    .font(.body.weight(.semibold))
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Reset") { draft = RecipeFilter() }
                        .disabled(!draft.isRestricting)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .tint(Theme.accent)
    }

    // MARK: Sections

    private var categorySection: some View {
        Section("Category") {
            row(
                title: "All Recipes",
                systemImage: "square.grid.2x2",
                selected: draft.category == nil
            ) {
                draft.category = nil
            }

            ForEach(categories) { category in
                row(
                    title: category.name,
                    systemImage: nil,
                    selected: draft.category == category.name
                ) {
                    draft.category = category.name
                }
            }
        }
    }

    private var displaySection: some View {
        Section("Display") {
            Toggle(isOn: $draft.favoritesOnly) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(Theme.accent)
                    Text("Favorites Only")
                    Spacer(minLength: 8)
                    Text("\(favoritesCount)")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            .tint(Theme.accent)
        }
    }

    // MARK: Ligne

    private func row(
        title: String,
        systemImage: String?,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(Theme.accent)
                        .frame(width: 22)
                } else {
                    Color.clear.frame(width: 22)
                }

                Text(title)

                Spacer(minLength: 8)

                if selected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Theme.accent)
                        .font(.body.weight(.semibold))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(Theme.neutral800)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

#Preview("Filtres") {
    FilterSheet(
        categories: MockMealService.categories,
        favoritesCount: 3,
        filter: RecipeFilter()
    ) { _ in }
}
