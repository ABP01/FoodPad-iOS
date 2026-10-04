//
//  HomeScreen.swift
//  FoodPad
//
//  Écran principal : en-tête, recherche, catégories, grille de recettes.
//  Traduction de `src/screens/HomeScreen.js`.
//  Voir MIGRATION_SWIFT.md § Phase 4.
//

import SwiftUI
import os

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var categories: [Category] = []
    @Published var meals: [Meal] = []
    @Published var activeCategory: String = LiveMealService.defaultCategory
    @Published var searchText: String = ""
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?

    private let service: MealService

    /// Tâche de recherche courante, annulée si l'utilisateur continue de taper.
    private var searchTask: Task<Void, Never>?

    init(service: MealService = LiveMealService()) {
        self.service = service
    }

    // MARK: - Chargement

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            // Les catégories et les recettes partent en parallèle.
            async let categoriesTask = service.fetchCategories()
            async let mealsTask = service.fetchMeals(category: activeCategory)

            let (loadedCategories, loadedMeals) = try await (categoriesTask, mealsTask)
            categories = loadedCategories
            meals = loadedMeals
            Diagnostics.write("""
            accueil OK
            categories: \(loadedCategories.count)
            recettes:   \(loadedMeals.count)
            ecran:      \(Int(ScreenMetrics.screenWidth))x\(Int(ScreenMetrics.screenHeight)) pt
            hauteur grille: \(Int(gridHeightForDiagnostics(count: loadedMeals.count))) pt
            """)
        } catch {
            errorMessage = error.localizedDescription
            Diagnostics.write("accueil ECHEC: \(error)")
        }

        isLoading = false
    }

    /// Changement de catégorie : vide la grille puis recharge.
    func selectCategory(_ name: String) {
        guard name != activeCategory else { return }
        activeCategory = name
        searchText = ""
        searchTask?.cancel()

        Task {
            isLoading = true
            errorMessage = nil
            meals = []
            do {
                meals = try await service.fetchMeals(category: name)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    /// Recherche différée de 400 ms, comme un clavier de recherche natif.
    func performSearch() {
        let query = searchText
        searchTask?.cancel()

        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Task { await reloadActiveCategory() }
            return
        }

        searchTask = Task {
            isLoading = true
            errorMessage = nil
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }

            do {
                meals = try await service.searchMeals(query: query)
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    /// Hauteur qu'`RecipesGrid` reservingait pour `count` recettes.
    /// Recalculée ici pour le fichier de diagnostic.
    private func gridHeightForDiagnostics(count: Int) -> CGFloat {
        guard count > 0 else { return 0 }
        var heights = [CGFloat.zero, CGFloat.zero]
        for index in 0..<count {
            let slot = heights[0] <= heights[1] ? 0 : 1
            heights[slot] += MasonryGrid.cardHeights(index) + 16
        }
        return max(0, (heights.max() ?? 0) - 16)
    }

    private func reloadActiveCategory() async {
        isLoading = true
        meals = []
        do {
            meals = try await service.fetchMeals(category: activeCategory)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Écran

struct HomeScreen: View {

    @StateObject private var viewModel: HomeViewModel
    var onSelect: (Meal) -> Void

    init(service: MealService = LiveMealService(), onSelect: @escaping (Meal) -> Void) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(service: service))
        self.onSelect = onSelect
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    HomeHeader()
                    HomeHeadline()

                    SearchBar(text: $viewModel.searchText) {
                        viewModel.performSearch()
                    }

                    if !viewModel.categories.isEmpty {
                        CategoryBar(
                            categories: viewModel.categories,
                            activeCategory: $viewModel.activeCategory,
                            onSelect: { viewModel.selectCategory($0) }
                        )
                    }

                    if let error = viewModel.errorMessage {
                        errorBanner(error)
                    }

                    if viewModel.isLoading && viewModel.meals.isEmpty {
                        // `mt-20` dans Recipes.js : 5rem = 80 px
                        Loading(topPadding: 80)
                            .frame(height: 30.hp())
                    } else {
                        RecipesGrid(
                            meals: viewModel.meals,
                            isSearching: !viewModel.searchText.isEmpty,
                            onSelect: onSelect
                        )
                    }
                }
                .padding(.horizontal, 16)   // mx-4  → 1rem   = 16
                .padding(.top, 56)           // pt-14 → 3.5rem = 56  (PAS un %)
                .padding(.bottom, 50)        // paddingBottom: 50
            }
        }
        .task { await viewModel.load() }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .font(.system(size: 12))
        .foregroundStyle(.white)
        .padding(12)
        .background(Theme.neutral700, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Navigation

struct HomeDestination {
    static let route = "home"
}

#Preview("Home — données simulées") {
    NavigationStack {
        HomeScreen(service: MockMealService()) { _ in }
    }
}
