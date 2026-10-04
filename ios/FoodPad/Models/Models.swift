//
//  Models.swift
//  FoodPad
//
//  Modèles de données, décodés depuis l'API TheMealDB.
//

import Foundation

// MARK: - Ingrédient

/// Un ingrédient et sa quantité.
///
/// L'API TheMealDB renvoie toujours 20 paires `strIngredient1…20` /
/// `strMeasure1…20`, dont la plupart sont vides. On ne conserve que les
/// paires réellement remplies.
struct Ingredient: Identifiable, Hashable {
    let name: String
    let measure: String

    var id: String { name }
}

// MARK: - Meal

/// Une recette.
///
/// ⚠️  Les champs autres que `idMeal` et `strMeal` sont **optionnels** : le
/// endpoint `filter.php` renvoie une version allégée (id, nom, image), alors
/// que `lookup.php` renvoie la fiche complète. Un seul type doit décoder les
/// deux réponses, sinon il faudrait deux modèles.
struct Meal: Identifiable, Hashable {

    let id: String
    let name: String
    let thumbnailURL: String?
    let category: String?
    let area: String?
    let instructions: String?
    let youtubeURL: String?
    let sourceURL: String?
    let tags: String?
    let ingredients: [Ingredient]

    var idMeal: String { id }
    var strMeal: String { name }
    var strMealThumb: String? { thumbnailURL }

    /// Vrai si la fiche a été chargée via `lookup.php` (recette détaillée).
    var isDetailLoaded: Bool { instructions != nil }

    var youtubeVideoID: String? {
        guard let youtubeURL else { return nil }
        // https://www.youtube.com/watch?v=XXXX  ->  XXXX
        return URLComponents(string: youtubeURL)?
            .queryItems?
            .first(where: { $0.name == "v" })?
            .value
    }
}

// MARK: - Category

/// Une catégorie de recettes (Bœuf, Poulet, Vegan…).
struct Category: Identifiable, Hashable {

    let id: String
    let name: String
    let thumbnailURL: String
    let summary: String?

    var idCategory: String { id }
    var strCategory: String { name }
    var strCategoryThumb: String { thumbnailURL }
}

// MARK: - Décodage

/// Clé de décodage dynamique, pour lire `strIngredient1`, `strIngredient2`…
/// sans déclarer 40 `CodingKeys` à la main.
private struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(_ string: String) {
        self.stringValue = string
        self.intValue = nil
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

/// Nombre de paires d'ingrédients exposées par TheMealDB.
private let ingredientFieldCount = 20

extension Meal: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)

        /// Lit une chaîne en ignorant les valeurs vides et le littéral "null"
        /// que l'API renvoie parfois.
        ///
        /// - Note: `try?` **aplatit** les optionnels en Swift 5 : un
        ///   `decode` qui renvoie `String?` give `String?` avec `try?`, pas
        ///   `String??`. D'où le `guard let` simple.
        func string(_ key: String) -> String? {
            guard let raw = try? container.decode(String.self, forKey: DynamicKey(key)) else {
                return nil
            }
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, trimmed != "null" else { return nil }
            return trimmed
        }

        guard let id = string("idMeal"), let name = string("strMeal") else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Recette sans idMeal ou strMeal")
            )
        }

        self.init(
            id: id,
            name: name,
            thumbnailURL: string("strMealThumb"),
            category: string("strCategory"),
            area: string("strArea"),
            instructions: string("strInstructions"),
            youtubeURL: string("strYoutube"),
            sourceURL: string("strSource"),
            tags: string("strTags"),
            ingredients: Self.decodeIngredients(from: container)
        )
    }

    /// Balaye les 20 paires `strIngredientN` / `strMeasureN` et ne garde que
    /// celles dont le nom est renseigné.
    private static func decodeIngredients(
        from container: KeyedDecodingContainer<DynamicKey>
    ) -> [Ingredient] {
        (1...ingredientFieldCount).compactMap { index in
            guard let name = try? container.decode(
                String.self, forKey: DynamicKey("strIngredient\(index)")
            ) else {
                return nil
            }

            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else { return nil }

            let measure = (try? container.decode(
                String.self, forKey: DynamicKey("strMeasure\(index)")
            )) ?? ""

            return Ingredient(name: trimmedName, measure: measure)
        }
    }
}

extension Category: Decodable {

    private enum CodingKeys: String, CodingKey {
        case idCategory, strCategory, strCategoryThumb, strCategoryDescription
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(String.self, forKey: .idCategory),
            name: try container.decode(String.self, forKey: .strCategory),
            thumbnailURL: try container.decode(String.self, forKey: .strCategoryThumb),
            summary: try container.decodeIfPresent(String.self, forKey: .strCategoryDescription)
        )
    }
}

// MARK: - Enveloppes de réponse

/// Enveloppe commune aux endpoints `filter.php` et `lookup.php`.
struct MealsResponse: Decodable {
    let meals: [Meal]
}

/// Enveloppe de l'endpoint `categories.php`.
struct CategoriesResponse: Decodable {
    let categories: [Category]
}
