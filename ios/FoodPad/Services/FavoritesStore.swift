//
//  FavoritesStore.swift
//  FoodPad
//
//  Persistance des recettes favorites.
//
//  ⚠️  L'app React Native d'origine ne les persiste PAS : `RecipeDetailsScreen`
//  utilise un simple `useState`, donc le cœur revient à l'état initial à chaque
//  lancement. C'est un défaut, pas une fonctionnalité — voir
//  MIGRATION_SWIFT.md § 5.2.
//
//  On le corrige au passage : c'est l'un des rares écarts assumés entre la
//  version RN et la version Swift.
//

import Foundation

@MainActor
final class FavoritesStore: ObservableObject {

    static let shared = FavoritesStore()

    private static let storageKey = "foodpad.favorites"

    /// Identifiants des recettes favorites, dans l'ordre d'ajout.
    @Published private(set) var ids: [String] = []

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func isFavorite(_ mealID: String) -> Bool {
        ids.contains(mealID)
    }

    /// Bascule l'état d'une recette. Renvoie le nouvel état.
    @discardableResult
    func toggle(_ mealID: String) -> Bool {
        if let index = ids.firstIndex(of: mealID) {
            ids.remove(at: index)
            save()
            return false
        }
        ids.append(mealID)
        save()
        return true
    }

    var count: Int { ids.count }

    // MARK: - Persistance

    private func load() {
        ids = defaults.stringArray(forKey: Self.storageKey) ?? []
    }

    private func save() {
        defaults.set(ids, forKey: Self.storageKey)
    }
}
