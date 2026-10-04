//
//  DevTools.swift
//  FoodPad
//
//  Aides au développement, compilées **uniquement en configuration Debug**.
//
//  Sans elles, on ne peut pas vérifier l'écran des favoris sur le simulateur :
//  le magasin démarre vide, et il n'y a aucun moyen de cliquer sur le cœur d'une
//  recette depuis la ligne de commande. L'argument `-seedFavorites N` remplit
//  donc le magasin avec N plats fictifs, et `-favoritesOnly` force le filtre
//  correspondant sur l'accueil.
//
//      xcrun simctl launch booted com.armelbogue.foodpad -startScreen favorites \
//          -seedFavorites 6
//      xcrun simctl launch booted com.armelbogue.foodpad -startScreen home \
//          -seedFavorites 6 -favoritesOnly
//
//  ⚠️  Tout le fichier est exclu de la configuration Release : aucun de ces
//  arguments n'existe dans l'app livrée.
//

#if DEBUG
import Foundation

enum DevTools {

    /// Vrai si l'argument de lancement est présent.
    static func hasFlag(_ flag: String) -> Bool {
        ProcessInfo.processInfo.arguments.contains(flag)
    }

    /// Lit la valeur entière qui suit `flag`, si elle existe et est valide.
    static func intValue(for flag: String) -> Int? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: flag),
              arguments.indices.contains(index + 1) else {
            return nil
        }
        return Int(arguments[index + 1])
    }

    /// Remplit le magasin de favoris avec des plats fictifs.
    ///
    /// Idempotent : le magasin est vidé d'abord, donc relancer l'app avec le
    /// même argument donne exactement le même résultat — indispensable pour
    /// des captures d'écran reproductibles.
    @MainActor
    static func seedFavoritesIfRequested() {
        guard let count = intValue(for: "-seedFavorites"), count > 0 else { return }

        let store = FavoritesStore.shared
        store.removeAll()
        for meal in MockMealService.meals.prefix(count) {
            store.toggle(meal)
        }

        Diagnostics.write("dev: \(count) favoris injectes")
    }
}
#endif
