<div align="center">

# 🍳 FoodPad

**Explorez des milliers de recettes, à votre rythme.**

Application iOS native en Swift / SwiftUI.

[![Swift](https://img.shields.io/badge/Swift-5.0-F05138?style=flat-square&logo=swift)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2016-0A7AFF?style=flat-square&logo=apple)](https://developer.apple.com/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](./LICENSE)

</div>

---

## 📱 À propos

FoodPad est une application de recettes qui permet de parcourir un large
catalogue, de filtrer par catégorie et de consulter le détail de chaque plat
(ingrédients, quantités, instructions).

Le projet est né d'une envie simple : disposer d'un carnet de recettes toujours
à jour, consultable hors ligne et agréable à utiliser sur téléphone.

### ✨ Fonctionnalités

- **Écran d'accueil animé** — logo Lottie et transition vers l'app en un clic
- **Navigation** — `NavigationStack` natif, en-têtes masqués, retour standard
- **Catégories** — 14 catégories (Bœuf, Poulet, Fruits de mer, Végétarien,
  Dessert, Vegan…) sélectionnables en un tap
- **Grille en maçonnerie** — 2 colonnes, hauteurs alternées, `Layout` maison
- **Fiche recette** — image plein cadre, origine, ingrédients, instructions
- **Recherche** — interroge l'API à la frappe, avec annulation et debounce
- **Filtres** — catégorie et mode « favoris uniquement », avec reset
- **Favoris** — persistés sur disque, consultables hors ligne
- **Liens utiles** — vidéo YouTube et fiche source quand la recette en fournit
- **Cache d'images** — disque via `FileManager` + `NSCache` mémoire
- **Accessibilité** — libellés VoiceOver sur chaque contrôle, états sélectionnés

### 🛠 Stack technique

| Couche | Technologie |
| --- | --- |
| Langage | Swift 5 |
| UI | SwiftUI (`ObservableObject`, iOS 16.0+) |
| Navigation | `NavigationStack` + `enum Route` typée |
| Grille | `Layout` SwiftUI maison (aucun paquet tiers) |
| Animation | `.spring` / `.easeOut`, Lottie (optionnel) |
| Réseau | `URLSession` async/await |
| Icônes | SF Symbols |
| Cache disque | `FileManager` + `NSCache` |
| Stockage | `UserDefaults` (JSON encodé) |
| API | [TheMealDB](https://www.themealdb.com/api.php) — gratuite, sans clé |

Aucune dépendance externe : le projet n'utilise que les frameworks système.

### 🔌 API utilisée

| Endpoint | Utilisation |
| --- | --- |
| `GET /categories.php` | Liste des catégories |
| `GET /filter.php?c={catégorie}` | Recettes filtrées par catégorie |
| `GET /lookup.php?i={id}` | Détail complet d'une recette |
| `GET /search.php?s={recherche}` | Recherche par nom |

---

## 🚀 Installation & lancement

**Prérequis :** macOS avec Xcode, et un simulateur iOS.

```bash
# Compiler
cd ios
xcodebuild -project FoodPad.xcodeproj -scheme FoodPad \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath /tmp/fp-dd build

# Installer et lancer sur le simulateur
xcrun simctl install booted /tmp/fp-dd/Build/Products/Debug-iphonesimulator/FoodPad.app
xcrun simctl launch booted com.armelbogue.foodpad
```

Ou ouvrir `ios/FoodPad.xcodeproj` dans Xcode et appuyer sur ▶.

### Outils de développement

En configuration **Debug** uniquement, l'app accepte des arguments de lancement
pour sauter directement à un écran et injecter des données :

```bash
xcrun simctl launch booted com.armelbogue.foodpad -startScreen home
xcrun simctl launch booted com.armelbogue.foodpad -startScreen favorites
xcrun simctl launch booted com.armelbogue.foodpad -startScreen details

# Remplir les favoris (le magasin démarre vide et on ne peut pas cliquer)
xcrun simctl launch booted com.armelbogue.foodpad \
  -startScreen favorites -seedFavorites 6

# Forcer le filtre « favoris uniquement »
xcrun simctl launch booted com.armelbogue.foodpad \
  -startScreen home -favoritesOnly
```

Le fichier `Components/DevTools.swift` est entièrement encadré par `#if DEBUG` :
l'app livrée démarre toujours sur l'écran d'accueil.

---

## 📁 Structure du projet

```
.
├── ios/
│   ├── FoodPad.xcodeproj/          # Projet Xcode (écrit à la main)
│   └── FoodPad/
│       ├── FoodPadApp.swift        # Point d'entrée + NavigationStack
│       ├── Theme/                  # Couleurs, typo, hp()/wp()
│       ├── DesignSystem/           # Écran de référence des tokens
│       ├── Models/                 # Meal, Category, Ingredient
│       ├── Services/               # MealService, cache, favoris
│       ├── Components/             # MasonryGrid, RecipeCard, CachedImage,
│       │                           #   FilterSheet, DevTools
│       ├── Screens/                # Welcome, Home, RecipeDetails, Favorites
│       ├── Resources/              # food-logo.json (animation Lottie)
│       └── Assets.xcassets/        # Icône, avatar, fond
├── docs/                           # Captures d'écran
└── scripts/                        # inspect-screenshot.py, generate-assets.py
```

Le groupe `FoodPad` est un *synchronized root group* : tout fichier `.swift` ou
`.xcassets` ajouté dans le dossier est intégré au projet sans modifier
`project.pbxproj`.

### Scripts

| Script | Rôle |
| --- | --- |
| `scripts/inspect-screenshot.py` | Analyse une capture : couleurs dominantes, présence de l'accent, profil vertical en 12 bandes |
| `scripts/generate-assets.py` | Régénère icône, avatar et fond d'accueil (encodeur PNG maison, aucune dépendance) |

---

## 🎬 Captures d'écran

| Welcome | Accueil | Fiche recette |
| --- | --- | --- |
| ![Welcome](docs/native-welcome.png) | ![Accueil](docs/native-home.png) | ![Fiche](docs/native-details.png) |

| Favoris | Favoris (vide) | Accueil filtré |
| --- | --- | --- |
| ![Favoris](docs/native-favorites.png) | ![Vide](docs/native-favorites-empty.png) | ![Filtre](docs/native-filter-favorites.png) |

Écran de référence du design system :
![Design system](docs/phase1-design-system.png)

---

## 📘 Notes techniques

**[MIGRATION_SWIFT.md](./MIGRATION_SWIFT.md)** — conception détaillée, décisions
arbitrées et pièges rencontrés. Utile si tu reprends le projet.

Points d'attention :

- **`hp()` est relatif à la hauteur d'écran.** `5.hp()` = 5 % de la hauteur. Le
  rendu se dégrade donc hors portrait et sur iPad. Un vrai passage au
  responsive design est un chantier séparé.
- **L'échelle d'espacement n'est pas la même que `hp()`.** Les multiples de 4 pt
  (marge de 56 pt, 64 pt, 80 pt…) sont des unités fixes, pas des pourcentages.
- **Les favoris stockent des entrées complètes** (`id`, `name`,
  `thumbnailURL`), pas des identifiants : l'écran doit s'afficher hors ligne.

---

## 🛤 Feuille de route

Terminé : recherche branchée, favoris persistés, cache disque des images,
feuilles de filtres, liens vers la vidéo et la source, visuels d'en-tête
générés.

Reste à faire :

- [ ] Ajouter Lottie (`#if canImport(Lottie)` est déjà en place) — la dépendance
      SPM n'a pas pu être résolue depuis cette machine, à faire depuis Xcode
- [ ] Mode hors ligne complet avec cache des réponses JSON
- [ ] Passer à un vrai responsive design (`@ScaledMetric` ou contraintes)
- [ ] Transition partagée image — exige iOS 18, or la cible est iOS 16
- [ ] Publier sur l'App Store

---

## 👤 Auteur

**Armel Bogue** — [GitHub](https://github.com)

---

## 📜 Crédits & licence

- MIT License — voir [`LICENSE`](./LICENSE)
- Recettes et images fournies par [TheMealDB](https://www.themealdb.com/api.php)

---

<div align="center">
<sub>Construit avec ❤️ en Swift &amp; SwiftUI</sub>
</div>