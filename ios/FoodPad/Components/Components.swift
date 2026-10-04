//
//  Components.swift
//  FoodPad
//
//  Composants transverses : indicateur de chargement, barre de recherche,
//  barre de catégories, en-tête d'accueil.
//  Traduction de `src/components/Loading.js`, `Categories.js` et des blocs
//  correspondants de `HomeScreen.js`.
//

import SwiftUI

// MARK: - Loading

/// Équivalent de `src/components/Loading.js` :
/// un `ActivityIndicator` centré verticalement et horizontalement.
struct Loading: View {

    var size: CGFloat = 2.5.hp()
    var topPadding: CGFloat = 0

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            ProgressView()
                .controlSize(.large)
                .tint(Theme.neutral600)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, topPadding)
    }
}

// MARK: - SearchBar

/// Barre de recherche de l'écran d'accueil.
///
/// Équivalent du `TextInput` entouré d'une bordure dans `HomeScreen.js` :
/// `border rounded-xl border-black p-[6px]`, loupe dans un cercle blanc.
struct SearchBar: View {

    @Binding var text: String
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            // Loupe sur fond blanc circulaire
            ZStack {
                Circle()
                    .fill(.white)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 1.6.hp(), weight: .bold))
                    .foregroundStyle(.gray)
            }
            .frame(width: 3.hp(), height: 3.hp())

            TextField("Search Your Favorite Food", text: $text)
                .font(Typo.searchPlaceholder)
                .tracking(Typo.searchTracking)
                .foregroundStyle(Theme.neutral800)
                .tint(Theme.accent)
                .submitLabel(.search)
                .onSubmit(onSubmit)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    text = ""
                    onSubmit()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(.black, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - CategoryBar

/// Barre horizontale de catégories.
///
/// Équivalent de `src/components/Categories.js` : `ScrollView` horizontal avec
/// `space-x-4` (16 pt) et `paddingHorizontal: 15`. La pastille de la
/// catégorie active estfilled en accent, les autres en noir à 10 %.
struct CategoryBar: View {

    let categories: [Category]
    @Binding var activeCategory: String
    var onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(categories) { category in
                    categoryItem(category)
                }
            }
            .padding(.horizontal, 15)
        }
    }

    private func categoryItem(_ category: Category) -> some View {
        let isActive = category.name == activeCategory

        return Button {
            onSelect(category.name)
        } label: {
            VStack(spacing: 4) {
                // Pastille : 6 pt de padding, rayon 12, image circulaire 6.hp()
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isActive ? Theme.accent : Theme.pillInactive)

                    CachedImage(url: category.thumbnailURL) { image in
                        image
                    } placeholder: {
                        Theme.cardPlaceholder
                    }
                    .frame(width: 6.hp(), height: 6.hp())
                    .clipShape(Circle())
                }
                .frame(width: 6.hp() + 12, height: 6.hp() + 12)

                Text(category.name)
                    .font(Typo.categoryLabel)
                    .foregroundStyle(Theme.neutral800)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(category.name)
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }
}

// MARK: - HomeHeader

/// En-tête de l'écran d'accueil : icône de filtres à gauche, avatar à droite,
/// puis les deux lignes de titre.
///
/// Équivalent du haut de `HomeScreen.js`.
///
/// ⚠️  Dans l'app d'origine ces deux éléments sont de simples `Image` sans
/// gestionnaire d'appui : rien ne se passait. Ils deviennent ici des `Button`
/// — l'icône ouvre les filtres, l'avatar les favoris.
struct HomeHeader: View {

    /// `true` si un filtre autre que « tout afficher » est actif. Ajoute un
    /// point d'accent sur l'icône pour que le filtre en cours soit visible
    /// d'un coup d'œil.
    var isFilterActive: Bool = false

    /// Nombre de favoris, affiché en pastille sur l'avatar.
    var favoritesCount: Int = 0

    var onOpenFilters: () -> Void
    var onOpenFavorites: () -> Void

    var body: some View {
        HStack {
            Button(action: onOpenFilters) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 2.2.hp(), weight: .regular))
                    .foregroundStyle(isFilterActive ? Theme.accent : .gray)
                    .frame(width: 5.hp(), height: 5.hp())
                    .overlay(alignment: .topTrailing) {
                        if isFilterActive {
                            Circle()
                                .fill(Theme.accent)
                                .frame(width: 6, height: 6)
                                .offset(x: 4, y: -2)
                        }
                    }
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel(isFilterActive ? "Filtres (actifs)" : "Filtres")

            Spacer()

            Button(action: onOpenFavorites) {
                Image("Avatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 5.hp(), height: 5.hp())
                    .clipShape(Circle())
                    .overlay(alignment: .topTrailing) {
                        // Pastille de compteur, seulement s'il y a des favoris.
                        if favoritesCount > 0 {
                            Text("\(min(favoritesCount, 99))")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .monospacedDigit()
                                .padding(.horizontal, 4)
                                .frame(minWidth: 14)
                                .background(Theme.accent, in: Capsule())
                                .offset(x: 6, y: -6)
                        }
                    }
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel(favoritesCount > 0
                                ? "Mes favoris (\(favoritesCount))"
                                : "Mes favoris")
        }
    }
}

/// Les deux lignes « Fast & Delicious » / « Food You Love ».
///
/// Le mot « Love » est coloré en accent via un `Text` imbriqué, comme dans
/// l'app d'origine.
struct HomeHeadline: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Fast & Delicious")
                .font(Typo.homeHeadline)
                .foregroundStyle(Theme.neutral800)

            (Text("Food You ").foregroundColor(Theme.neutral800)
             + Text("Love").foregroundColor(Theme.accent))
                .font(Typo.homeHeadlineAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - RecipesHeader

/// Ligne « 14 Recipes » au-dessus de la grille.
struct RecipesHeader: View {

    var count: Int

    var body: some View {
        Text("\(count) Recipes")
            .font(Typo.recipesCount)
            .foregroundStyle(Theme.neutral600)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
