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

    /// Restriction « favoris uniquement », posée par la feuille de filtres.
    @Published var favoritesOnly: Bool = false

    private let service: MealService
    private let favorites: FavoritesStore

    /// Tâche de recherche courante, annulée si l'utilisateur continue de taper.
    private var searchTask: Task<Void, Never>?

    init(service: MealService = LiveMealService(), favorites: FavoritesStore? = nil) {
        self.service = service
        // Le paramètre est optionnel plutôt que valoré à `.shared` : une
        // expression d'argument par défaut est évaluée dans un contexte non
        // isolé, alors que `FavoritesStore` est isolé sur le main actor.
        self.favorites = favorites ?? .shared

        #if DEBUG
        // Permet de vérifier le rendu du filtre « favoris uniquement » sans
        // ouvrir la feuille de filtres. Voir DevTools.swift.
        if DevTools.hasFlag("-favoritesOnly") {
            self.favoritesOnly = true
        }
        #endif
    }

    // MARK: - Vue filtrée

    /// Vrai dès qu'au moins une recette a été reçue, indépendamment du filtre.
    ///
    /// Permet de distinguer « encore en chargement » de « filtre qui ne laisse
    /// rien passer » : les deux se traduisent par une grille vide.
    var hasAnyMeal: Bool { !meals.isEmpty }

    /// Filtre courant, tel que présenté dans la feuille.
    var filter: RecipeFilter {
        // `activeCategory` vaut toujours une catégorie concrète ; on ne
        // restitue une sélection explicite que si elle diffère du défaut.
        RecipeFilter(
            category: activeCategory == LiveMealService.defaultCategory ? nil : activeCategory,
            favoritesOnly: favoritesOnly
        )
    }

    /// Recettes réellement affichées, filtre « favoris » appliqué.
    ///
    /// Une liste vide ici est un cas distinct de « aucune recette » : d'où
    /// `isFavoritesFilterHidingEverything` pour adapter le message affiché.
    var visibleMeals: [Meal] {
        favoritesOnly ? favorites.favorites(in: meals) : meals
    }

    /// Vrai quand le filtre actif masque tout : la catégorie a des recettes,
    /// mais aucune n'est favorite.
    var isFavoritesFilterHidingEverything: Bool {
        favoritesOnly && !meals.isEmpty && visibleMeals.isEmpty
    }

    var favoritesCount: Int { favorites.count }

    // MARK: - Filtres

    /// Applique un filtre venu de la feuille.
    ///
    /// Seul un changement de catégorie déclenche un appel réseau ; basculer le
    /// mode favoris se fait localement, sans rechargement.
    func applyFilter(_ newFilter: RecipeFilter) {
        favoritesOnly = newFilter.favoritesOnly

        let newCategory = newFilter.resolvedCategory
        guard newCategory != activeCategory else { return }

        activeCategory = newCategory
        searchText = ""
        searchTask?.cancel()

        Task { await reloadActiveCategory() }
    }

    /// Retire le mode « favoris uniquement ».
    func clearFavoritesOnly() {
        favoritesOnly = false
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
    var onOpenFavorites: () -> Void

    @State private var isPresentingFilters = false

    init(
        service: MealService = LiveMealService(),
        onSelect: @escaping (Meal) -> Void,
        onOpenFavorites: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(service: service))
        self.onSelect = onSelect
        self.onOpenFavorites = onOpenFavorites
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    HomeHeader(
                        isFilterActive: viewModel.filter.isRestricting,
                        favoritesCount: viewModel.favoritesCount,
                        onOpenFilters: { isPresentingFilters = true },
                        onOpenFavorites: onOpenFavorites
                    )
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

                    if viewModel.favoritesOnly {
                        activeFilterChip
                    }

                    if let error = viewModel.errorMessage {
                        errorBanner(error)
                    }

                    grid
                }
                .padding(.horizontal, 16)   // mx-4  → 1rem   = 16
                .padding(.top, 56)           // pt-14 → 3.5rem = 56  (PAS un %)
                .padding(.bottom, 50)        // paddingBottom: 50
            }
        }
        .task { await viewModel.load() }
        .sheet(isPresented: $isPresentingFilters) {
            FilterSheet(
                categories: viewModel.categories,
                favoritesCount: viewModel.favoritesCount,
                filter: viewModel.filter
            ) { filter in
                viewModel.applyFilter(filter)
            }
        }
    }

    // MARK: Grille

    @ViewBuilder
    private var grid: some View {
        if viewModel.isLoading && !viewModel.hasAnyMeal {
            // `mt-20` dans Recipes.js : 5rem = 80 px
            Loading(topPadding: 80)
                .frame(height: 30.hp())
        } else if viewModel.isFavoritesFilterHidingEverything {
            noFavoriteInCategory
        } else {
            RecipesGrid(
                meals: viewModel.visibleMeals,
                isSearching: !viewModel.searchText.isEmpty,
                onSelect: onSelect
            )
        }
    }

    // MARK: Messages

    /// Rappel du filtre actif, avec une sortie à un geste.
    private var activeFilterChip: some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .foregroundStyle(Theme.accent)

            Text("Favorites Only")
                .font(Typo.categoryLabel)

            Spacer(minLength: 8)

            Button {
                viewModel.clearFavoritesOnly()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.neutral500)
                    .padding(6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Retirer le filtre favoris")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.pillInactive, in: Capsule())
    }

    private var noFavoriteInCategory: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.slash")
                .font(.system(size: 5.hp(), weight: .light))
                .foregroundStyle(Theme.neutral500.opacity(0.5))

            Text("No favorite in \(viewModel.activeCategory)")
                .font(Typo.categoryLabel)
                .foregroundStyle(Theme.neutral600)

            Button("Show all \(viewModel.activeCategory)") {
                viewModel.clearFavoritesOnly()
            }
            .font(Typo.categoryLabel.weight(.semibold))
            .foregroundStyle(Theme.accent)
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8.hp())
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
