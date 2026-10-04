//
//  MealService.swift
//  FoodPad
//
//  Couche réseau. Remplace `axios` dans l'app React Native.
//  Voir MIGRATION_SWIFT.md § Phase 2.
//
//  API publique et gratuite, aucune clé requise : https://www.themealdb.com/api.php
//

import Foundation

// MARK: - Erreurs

enum MealServiceError: LocalizedError {
    case badURL(String)
    case badStatus(Int)
    case emptyPayload
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .badURL(let url):
            return "URL invalide : \(url)"
        case .badStatus(let code):
            return "Le serveur a répondu \(code)."
        case .emptyPayload:
            return "Aucune donnée renvoyée."
        case .transport(let error):
            return "Erreur réseau : \(error.localizedDescription)"
        }
    }
}

// MARK: - Protocole

/// Abstraction du service de données.
///
/// Permet de substituer `LiveMealService` par `MockMealService` pour
/// développer et prévisualiser l'interface sans réseau — utile sur simulateur,
/// où les appels HTTPS peuvent être lents ou bloqués.
protocol MealService {
    func fetchCategories() async throws -> [Category]
    func fetchMeals(category: String) async throws -> [Meal]
    func fetchMealDetail(id: String) async throws -> Meal
    func searchMeals(query: String) async throws -> [Meal]
}

// MARK: - Implémentation réelle

struct LiveMealService: MealService {

    static let defaultCategory = "Beef"

    private let session: URLSession
    private let baseURL = URL(string: "https://www.themealdb.com/api/json/v1/1/")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: Endpoints

    /// `GET categories.php`
    func fetchCategories() async throws -> [Category] {
        let response: CategoriesResponse = try await get("categories.php")
        return response.categories
    }

    /// `GET filter.php?c={category}`
    ///
    /// ⚠️  Renvoie des recettes **sans ingrédients** : c'est la fiche résumée.
    /// L'écran de détails refait un appel `lookup.php` pour le détail complet.
    func fetchMeals(category: String) async throws -> [Meal] {
        guard let url = URL(string: "filter.php?c=\(category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category)",
                            relativeTo: baseURL) else {
            throw MealServiceError.badURL("filter.php?c=\(category)")
        }
        let response: MealsResponse = try await get(url)
        return response.meals
    }

    /// `GET lookup.php?i={id}`
    func fetchMealDetail(id: String) async throws -> Meal {
        let response: MealsResponse = try await get("lookup.php?i=\(id)")
        guard let meal = response.meals.first else {
            throw MealServiceError.emptyPayload
        }
        return meal
    }

    /// `GET search.php?s={query}`
    ///
    /// Utilisé par la barre de recherche de l'accueil. Dans l'app React Native
    /// d'origine ce champ est décoratif (non câblé) — ici il devient
    /// fonctionnel.
    func searchMeals(query: String) async throws -> [Meal] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        guard let url = URL(string: "search.php?s=\(trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed)",
                            relativeTo: baseURL) else {
            throw MealServiceError.badURL("search.php?s=\(trimmed)")
        }
        let response: MealsResponse = try await get(url)
        return response.meals
    }

    // MARK: Transport

    private func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw MealServiceError.badURL(path)
        }
        return try await get(url)
    }

    private func get<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw MealServiceError.transport(error)
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw MealServiceError.badStatus(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw MealServiceError.emptyPayload
        }
    }
}
