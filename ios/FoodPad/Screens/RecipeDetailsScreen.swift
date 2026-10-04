//
//  RecipeDetailsScreen.swift
//  FoodPad
//
//  Fiche détaillée d'une recette.
//  Traduction de `src/screens/RecipeDetailsScreen.js`.
//  Voir MIGRATION_SWIFT.md § Phase 6.
//

import SwiftUI

// MARK: - ViewModel

@MainActor
final class RecipeDetailsViewModel: ObservableObject {

    /// Recette reçue depuis la grille : sufficient pour afficher le nom et
    /// l'image immédiatement, avant la réponse réseau.
    @Published var meal: Meal
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?

    private let service: MealService
    private let favorites: FavoritesStore

    init(meal: Meal, service: MealService = LiveMealService(),
         favorites: FavoritesStore = .shared) {
        self.meal = meal
        self.service = service
        self.favorites = favorites
    }

    var isFavorite: Bool { favorites.isFavorite(meal.id) }

    func toggleFavorite() {
        favorites.toggle(meal.id)
        objectWillChange.send()
    }

    /// Charge la fiche complète.
    ///
    /// ⚠️  L'app React Native utilise un `useEffect` **sans tableau de
    /// dépendances**, ce qui relance l'appel réseau à chaque rendu. Ici le
    /// `.task` de la vue ne s'exécute qu'une fois — ce bug est donc corrigé.
    func load() async {
        guard !meal.isDetailLoaded else {
            isLoading = false
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            meal = try await service.fetchMealDetail(id: meal.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Écran

struct RecipeDetailsScreen: View {

    @StateObject private var viewModel: RecipeDetailsViewModel
    @Environment(\.dismiss) private var dismiss

    init(meal: Meal, service: MealService = LiveMealService()) {
        _viewModel = StateObject(
            wrappedValue: RecipeDetailsViewModel(meal: meal, service: service)
        )
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    heroImage
                    sheetContent
                }
                .padding(.bottom, 30)
            }
            .ignoresSafeArea(edges: .top)

            topBar
        }
        .task { await viewModel.load() }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Image héro

    private var heroImage: some View {
        CachedImage(url: viewModel.meal.thumbnailURL) { image in
            image
        } placeholder: {
            Theme.cardPlaceholder
        }
        .frame(width: ScreenMetrics.screenWidth, height: 45.hp())
        .clipped()
    }

    // MARK: Barre supérieure

    private var topBar: some View {
        HStack {
            circleButton(systemName: "chevron.left", tint: Theme.accent) {
                dismiss()
            }
            Spacer()
            circleButton(
                systemName: viewModel.isFavorite ? "heart.fill" : "heart",
                tint: viewModel.isFavorite ? Theme.accent : .gray
            ) {
                viewModel.toggleFavorite()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 14.hp())
    }

    private func circleButton(systemName: String, tint: Color,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 2.hp(), weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 4.hp(), height: 4.hp())
                .background(.white, in: Circle())
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel(systemName == "chevron.left" ? "Retour" : "Favori")
    }

    // MARK: Feuille de contenu

    private var sheetContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading {
                // `mt-16` dans l'app RN : 4rem = 64 px (pas un pourcentage)
                Loading(topPadding: 64)
                    .frame(height: 20.hp())
            } else {
                titleBlock
                ingredientsBlock
                instructionsBlock
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 3.hp())
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            // Coins arrondis en haut, le contenu chevauchant l'image
            UnevenRoundedRectangle(
                topLeadingRadius: 50,
                topTrailingRadius: 50,
                style: .continuous
            )
            .fill(.white)
        )
        // Chevauchement : `mt-[-46]` dans l'app React Native
        .offset(y: -46)
        .padding(.top, 46)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(viewModel.meal.name)
                .font(Typo.detailMealName)
                .foregroundStyle(Theme.neutral700)

            if let area = viewModel.meal.area {
                Text(area)
                    .font(Typo.detailArea)
                    .foregroundStyle(Theme.neutral500)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(detailAnimation(delay: 0.2), value: viewModel.meal.name)
    }

    private var ingredientsBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ingredients")
                .font(Typo.detailSectionTitle)
                .foregroundStyle(Theme.neutral700)

            if viewModel.meal.ingredients.isEmpty {
                Text("No ingredient listed for this recipe.")
                    .font(Typo.instructions)
                    .foregroundStyle(Theme.neutral500)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.meal.ingredients) { ingredient in
                        ingredientRow(ingredient)
                    }
                }
                .padding(.leading, 12)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(detailAnimation(delay: 0.3), value: viewModel.meal.ingredients.count)
    }

    private func ingredientRow(_ ingredient: Ingredient) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Circle()
                .fill(Theme.accent)
                .frame(width: 1.5.hp(), height: 1.5.hp())
                .alignmentGuide(.firstTextBaseline) { $0[.bottom] - 1.5.hp() / 2 }

            HStack(spacing: 8) {
                Text(ingredient.name)
                    .font(Typo.ingredientName)
                    .foregroundStyle(Theme.neutral800)

                Text(ingredient.measure)
                    .font(Typo.ingredientMeasure)
                    .foregroundStyle(Theme.neutral700)
            }
        }
    }

    private var instructionsBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Instructions")
                .font(Typo.detailSectionTitle)
                .foregroundStyle(Theme.neutral700)

            Text(viewModel.meal.instructions ?? "No instructions listed for this recipe.")
                .font(Typo.instructions)
                .foregroundStyle(Theme.neutral700)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(detailAnimation(delay: 0.4), value: viewModel.isLoading)
    }

    // MARK: Animation

    /// Reproduit `.duration(700).springify().damping(12)` de Reanimated.
    ///
    /// ⚠️  ReAnimated n'a pas d'équivalent exact en SwiftUI. `dampingFraction`
    /// 0.7 donne un rendu proche ; à ajuster à l'œil si l'animation paraît
    /// trop ferme ou trop molle. Voir MIGRATION_SWIFT.md § 5.1.
    private func detailAnimation(delay: Double) -> Animation {
        .spring(response: 0.7, dampingFraction: 0.7)
            .delay(delay)
    }
}

// MARK: - Navigation

struct RecipeDetailsDestination {
    static let route = "recipeDetails"
}

#Preview("Fiche recette") {
    NavigationStack {
        RecipeDetailsScreen(meal: MockMealService.detailedMeals[0],
                            service: MockMealService())
    }
}
