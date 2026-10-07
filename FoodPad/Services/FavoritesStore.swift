//
//  FavoritesStore.swift
//  FoodPad
//
//  Persistance des recettes favorites.
//
//  ⚠️  On stocke des **entrées complètes** et pas seulement des
//  identifiants. L'écran « Mes favoris » doit s'afficher hors ligne, au
//  lancement, sans attendre un appel réseau : il lui faut le nom et l'image de
//  chaque plat. Stocker `["52771", "52844"]` ne suffirait pas.
//

import Foundation

// MARK: - Entrée persistée

/// Ce qu'on retient d'une recette favorite.
///
/// Volontairement minimaliste : l'identité, le nom et l'image. Le reste
/// (ingrédients, instructions) est récupéré à l'ouverture via `lookup.php` —
/// inutile de dupliquer en mémoire ce que l'API sait fournir à jour.
struct FavoriteEntry: Codable, Hashable, Identifiable {

    let id: String
    let name: String
    let thumbnailURL: String?

    init(id: String, name: String, thumbnailURL: String?) {
        self.id = id
        self.name = name
        self.thumbnailURL = thumbnailURL
    }

    init(_ meal: Meal) {
        self.init(id: meal.id, name: meal.name, thumbnailURL: meal.thumbnailURL)
    }

    /// Reconstitue une `Meal` partielle, suffisant pour l'affichage dans la
    /// grille et pour l'ouverture de la fiche détaillée (qui recharge).
    var meal: Meal {
        Meal(
            id: id,
            name: name,
            thumbnailURL: thumbnailURL,
            category: nil,
            area: nil,
            instructions: nil,
            youtubeURL: nil,
            sourceURL: nil,
            tags: nil,
            ingredients: []
        )
    }
}

// MARK: - Store

@MainActor
final class FavoritesStore: ObservableObject {

    static let shared = FavoritesStore()

    /// Version 2 : le format v1 ne contenait qu'un tableau d'identifiants,
    /// insuffisant pour afficher une liste hors ligne.
    private static let storageKey = "foodpad.favorites.v2"

    /// Favoris, **dans l'ordre d'ajout**. Cet ordre est conservé pour que la
    /// liste ne se réordonne pas à chaque ouverture.
    @Published private(set) var favorites: [FavoriteEntry] = []

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    // MARK: - Lecture

    var count: Int { favorites.count }

    var ids: [String] { favorites.map(\.id) }

    var meals: [Meal] { favorites.map(\.meal) }

    func isFavorite(_ mealID: String) -> Bool {
        favorites.contains { $0.id == mealID }
    }

    func entry(for mealID: String) -> FavoriteEntry? {
        favorites.first { $0.id == mealID }
    }

    /// Recettes de `meals` qui sont favorites, dans leur ordre d'origine.
    /// Sert à filtrer la grille de l'accueil.
    func favorites(in meals: [Meal]) -> [Meal] {
        let favoriteIDs = Set(ids)
        return meals.filter { favoriteIDs.contains($0.id) }
    }

    // MARK: - Écriture

    /// Bascule l'état d'une recette. Renvoie le nouvel état.
    @discardableResult
    func toggle(_ meal: Meal) -> Bool {
        if let index = favorites.firstIndex(where: { $0.id == meal.id }) {
            favorites.remove(at: index)
            save()
            return false
        }
        favorites.append(FavoriteEntry(meal))
        save()
        return true
    }

    func remove(_ mealID: String) {
        guard let index = favorites.firstIndex(where: { $0.id == mealID }) else { return }
        favorites.remove(at: index)
        save()
    }

    func removeAll() {
        favorites.removeAll()
        save()
    }

    /// Remplace l'entrée d'une recette par sa version la plus complète.
    ///
    /// Appelé après `lookup.php` : le plat favorite gagne alors son origine et
    /// ses ingrédients dans le stockage, donc dans l'écran des favoris.
    func enrich(_ meal: Meal) {
        guard let index = favorites.firstIndex(where: { $0.id == meal.id }) else { return }
        let enriched = FavoriteEntry(
            id: favorites[index].id,
            name: meal.name,
            thumbnailURL: meal.thumbnailURL ?? favorites[index].thumbnailURL
        )
        guard enriched != favorites[index] else { return }
        favorites[index] = enriched
        save()
    }

    // MARK: - Persistance

    private func load() {
        guard let data = defaults.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([FavoriteEntry].self, from: data)
        else {
            favorites = []
            return
        }
        favorites = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(favorites) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
