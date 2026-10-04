//
//  MockMealService.swift
//  FoodPad
//
//  Faux service de données, pour développer l'interface sans réseau.
//
//  Utile pour :
//  - les SwiftUI Previews (instantanés, hors ligne)
//  - le développement de la grille en maçonnerie (phase 5), qui est le
//    chantier le plus long et n'a pas besoin de données réelles
//  - les tests de capture d'écran reproductibles
//
//  Les données reprennent la forme exacte des réponses de TheMealDB,
//  y compris les champs d'ingrédients vides aux indices 6 à 20.
//

import Foundation

struct MockMealService: MealService {

    /// Latence simulée, pour rendre l'état de chargement visible.
    var latency: Duration = .milliseconds(250)

    private func pause() async throws {
        try? await Task.sleep(for: latency)
    }

    func fetchCategories() async throws -> [Category] {
        try await pause()
        return Self.categories
    }

    func fetchMeals(category: String) async throws -> [Meal] {
        try await pause()
        return Self.meals
    }

    func fetchMealDetail(id: String) async throws -> Meal {
        try await pause()
        // Retourne la version « détaillée » si on la connaît.
        return Self.detailedMeals.first { $0.id == id }
            ?? Self.meals.first { $0.id == id }
            ?? Self.meals[0]
    }

    func searchMeals(query: String) async throws -> [Meal] {
        try await pause()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return Self.meals }
        return Self.meals.filter { $0.name.lowercased().contains(trimmed) }
    }

    // MARK: - Données

    static let categories: [Category] = [
        Category(id: "1", name: "Beef",
                 thumbnailURL: "https://www.themealdb.com/images/category/beef.png",
                 summary: "Bœuf"),
        Category(id: "2", name: "Chicken",
                 thumbnailURL: "https://www.themealdb.com/images/category/chicken.png",
                 summary: "Poulet"),
        Category(id: "3", name: "Pork",
                 thumbnailURL: "https://www.themealdb.com/images/category/pork.png",
                 summary: "Porc"),
        Category(id: "4", name: "Seafood",
                 thumbnailURL: "https://www.themealdb.com/images/category/seafood.png",
                 summary: "Fruits de mer"),
        Category(id: "5", name: "Vegetarian",
                 thumbnailURL: "https://www.themealdb.com/images/category/vegetarian.png",
                 summary: "Végétarien"),
        Category(id: "6", name: "Dessert",
                 thumbnailURL: "https://www.themealdb.com/images/category/dessert.png",
                 summary: "Dessert"),
        Category(id: "7", name: "Lamb",
                 thumbnailURL: "https://www.themealdb.com/images/category/lamb.png",
                 summary: "Agneau"),
        Category(id: "8", name: "Pasta",
                 thumbnailURL: "https://www.themealdb.com/images/category/pasta.png",
                 summary: "Pâtes"),
        Category(id: "9", name: "Miscellaneous",
                 thumbnailURL: "https://www.themealdb.com/images/category/miscellaneous.png",
                 summary: "Divers"),
        Category(id: "10", name: "Vegan",
                 thumbnailURL: "https://www.themealdb.com/images/category/vegan.png",
                 summary: "Végétalien"),
    ]

    /// Version allégée, telle que renvoyée par `filter.php` :
    /// ni ingrédients, ni instructions, ni origine.
    static let meals: [Meal] = [
        .mock("52771", "Spicy Arrabiata", "Beef"),
        .mock("52855", "Baked salmon with fennel", "Seafood"),
        .mock("52959", "Chicken Basquaise", "Chicken"),
        .mock("53013", "Big Mac", "Beef"),
        .mock("52844", "Lasagne", "Pasta"),
        .mock("52768", "Apple Frangipan Tart", "Dessert"),
        .mock("52765", "Turkish Apple Pie", "Dessert"),
        .mock("52772", "Teriyaki Chicken Casserole", "Chicken"),
        .mock("52952", "Peanut Butter Chocolate Cake", "Dessert"),
        .mock("52781", "Irish Beef Stew", "Beef"),
        .mock("52839", "Chocolate Gateau", "Dessert"),
        .mock("53006", "Chicken Parmesan", "Chicken"),
        .mock("52792", "Honey Teriyaki Salmon", "Seafood"),
        .mock("52895", "Corba", "Pasta"),
        .mock("52817", "Pad See Ew", "Pasta"),
        .mock("52788", "Beef Wellington", "Beef"),
        .mock("52831", "Mushroom and Barley Soup", "Miscellaneous"),
        .mock("52895", "Red Lentil Soup", "Vegan"),
    ]

    /// Version détaillée, avec ingrédients et instructions.
    static let detailedMeals: [Meal] = [
        Meal(
            id: "52771",
            name: "Spicy Arrabiata",
            thumbnailURL: "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg",
            category: "Beef",
            area: "Italian",
            instructions: """
            Heat 1 tablespoon of olive oil on a large pan and lightly fry the \
            chopped onion and sliced garlic until translucent.

            Add the spaghetti and stir in the tomato puree with the basil, \
            chilli flakes and sugar. Season with salt and pepper.

            Simmer for 15-20 minutes until the pasta is cooked but still al \
            dente. When the pasta is almost ready, add the lamb and stir for \
            a final minute.
            """,
            youtubeURL: "https://www.youtube.com/watch?v=1-SJGQ2HLp8",
            sourceURL: "https://www.themealdb.com/meal/52771",
            tags: "Pasta,Curry",
            ingredients: [
                Ingredient(name: "Linguine", measure: "400g"),
                Ingredient(name: "Tomatoes", measure: "4"),
                Ingredient(name: "Red Pepper", measure: "1"),
                Ingredient(name: "Onion", measure: "1"),
                Ingredient(name: "Olive Oil", measure: "2 tbsp"),
                Ingredient(name: "Garlic", measure: "4 cloves"),
                Ingredient(name: "Basil", measure: "1 bunch"),
                Ingredient(name: "Chilli Flakes", measure: "1 tsp"),
                Ingredient(name: "Sugar", measure: "1 tsp"),
                Ingredient(name: "Salt", measure: "to taste"),
            ]
        ),
        Meal(
            id: "52844",
            name: "Lasagne",
            thumbnailURL: "https://www.themealdb.com/images/media/meals/wtsvxx1511296896.jpg",
            category: "Pasta",
            area: "Italian",
            instructions: """
            Preheat the oven to 180C. Cook the lasagne sheets in a large pot \
            of salted boiling water until they are soft but firm.

            Fry the minced beef and onion in a deep pan until brown, then add \
            the tomato puree, oregano and a splash of water. Simmer for 15 \
            minutes.

            Layer the lasagne with the beef sauce, the cream sauce and the \
            cheese. Repeat the layers and finish with cheese on top.

            Bake for 45 minutes until golden and bubbling.
            """,
            youtubeURL: "https://www.youtube.com/watch?v=6isS6tbIDxQ",
            sourceURL: "https://www.themealdb.com/meal/52844",
            tags: "Pasta,Meat",
            ingredients: [
                Ingredient(name: "Lasagne Sheets", measure: "12"),
                Ingredient(name: "Minced Beef", measure: "500g"),
                Ingredient(name: "Onion", measure: "1"),
                Ingredient(name: "Tomato Puree", measure: "400g"),
                Ingredient(name: "Cream", measure: "300ml"),
                Ingredient(name: "Mozzarella", measure: "200g"),
                Ingredient(name: "Parmesan", measure: "100g"),
                Ingredient(name: "Oregano", measure: "1 tsp"),
            ]
        ),
    ]
}

private extension Meal {

    /// Constructeur rapide pour les fiches résumées.
    static func mock(_ id: String, _ name: String, _ category: String) -> Meal {
        // URL d'image réelle, pour que l'écran montre bien les visuels
        // même sans réponse de l'API.
        let slug = name
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        return Meal(
            id: id,
            name: name,
            thumbnailURL: "https://www.themealdb.com/images/media/meals/\(slug).jpg",
            category: category,
            area: nil,
            instructions: nil,
            youtubeURL: nil,
            sourceURL: nil,
            tags: nil,
            ingredients: []
        )
    }
}
