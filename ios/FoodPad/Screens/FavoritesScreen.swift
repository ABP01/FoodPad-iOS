//
//  FavoritesScreen.swift
//  FoodPad
//
//  Écran « Mes favoris », ouvert depuis l'avatar de l'accueil.
//
//  Le contenu s'affiche **hors ligne** : `FavoritesStore` conserve le nom et
//  l'image de chaque favori, donc l'écran est complet dès la première seconde,
//  avant tout appel réseau.
//

import SwiftUI

//  `@MainActor` : `FavoritesStore` est isolé sur le main actor, et l'argument
//  par défaut `.shared` est évalué dans un contexte non isolé — sans
//  l'annotation, le compilateur refuse (erreur en Swift 6).
@MainActor
struct FavoritesScreen: View {

    @ObservedObject private var favorites: FavoritesStore
    var onSelect: (Meal) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmingClear = false

    init(favorites: FavoritesStore? = nil,
         onSelect: @escaping (Meal) -> Void) {
        // Paramètre optionnel plutôt que valoré à `.shared` : une expression
        // d'argument par défaut est évaluée dans un contexte non isolé, alors
        // que `FavoritesStore` est isolé sur le main actor.
        self.favorites = favorites ?? .shared
        self.onSelect = onSelect
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    if favorites.count == 0 {
                        emptyState
                    } else {
                        RecipesGrid(meals: favorites.meals) { meal in
                            onSelect(meal)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 56)
                .padding(.bottom, 50)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog(
            "Remove all \(favorites.count) favorites?",
            isPresented: $isConfirmingClear,
            titleVisibility: .visible
        ) {
            Button("Remove All", role: .destructive) {
                favorites.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    // MARK: En-tête

    private var header: some View {
        HStack {
            backButton

            Text("My Favorites")
                .font(Typo.homeHeadline)
                .foregroundStyle(Theme.neutral800)
                .lineLimit(1)

            Spacer(minLength: 8)

            if favorites.count > 0 {
                Button {
                    isConfirmingClear = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 2.hp(), weight: .regular))
                        .foregroundStyle(.gray)
                        .frame(width: 4.hp(), height: 4.hp())
                }
                .buttonStyle(PressableStyle())
                .accessibilityLabel("Effacer tous les favoris")
            }
        }
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 2.hp(), weight: .bold))
                .foregroundStyle(Theme.accent)
                .frame(width: 4.hp(), height: 4.hp())
                .background(.white, in: Circle())
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel("Retour")
    }

    // MARK: État vide

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 8.hp(), weight: .light))
                .foregroundStyle(Theme.accent.opacity(0.35))
                .padding(.top, 12.hp())

            Text("No Favorites Yet")
                .font(Typo.detailMealName)
                .foregroundStyle(Theme.neutral700)

            Text("Tap the heart on any recipe to keep it here for later.")
                .font(Typo.instructions)
                .foregroundStyle(Theme.neutral500)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                dismiss()
            } label: {
                Text("Browse Recipes")
                    .font(Typo.welcomeButton)
                    .foregroundStyle(Theme.accent)
                    .padding(.vertical, 1.2.hp())
                    .padding(.horizontal, 4.hp())
                    .background(.white, in: RoundedRectangle(cornerRadius: 1.5.hp()))
            }
            .buttonStyle(PressableStyle())
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Favoris — vide") {
    NavigationStack {
        FavoritesScreen(favorites: FavoritesStore(defaults: .standard)) { _ in }    }
}
