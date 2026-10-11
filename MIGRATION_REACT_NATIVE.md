# Plan de migration : SwiftUI natif → React Native

> **Statut** : plan de travail
> **Source** : application iOS native Swift / SwiftUI (dossier `FoodPad/`), iOS 16+
> **Cible** : React Native (Expo, *New Architecture*), TypeScript, iOS **et** Android
> **Objectif** : rendu **pixel-perfect** identique à l'app SwiftUI actuelle
> **Auteur de la référence visuelle** : les captures `docs/*.png` de ce dépôt

---

## 0. En une page

**Ce n'est pas un portage, c'est une seconde réécriture.** Le projet a déjà fait
le trajet inverse : l'app est née en React Native, a été réécrite en SwiftUI
(voir `MIGRATION_SWIFT.md`, conservé dans l'historique Git), et on repart
maintenant vers React Native.

Bonne nouvelle : **on connaît le code d'origine iOS**, on connaît le code React
Native d'origine, et on a une **référence visuelle figée** (les captures). C'est
la situation idéale pour viser le pixel.

**Règle d'or de ce chantier** : la référence, ce n'est **pas** l'ancienne app
React Native (elle avait des bugs : favoris non persistés, `useEffect` sans
dépendances, cache base64 dans `AsyncStorage`). La référence, c'est **l'app
SwiftUI actuelle**. On réécrit donc le comportement *corrigé*, pas les bugs.

**Charge estimée** (profil à l'aise avec RN) :

| Phase | Contenu | Charge | Difficulté |
| --- | --- | --- | --- |
| 0 | Socle projet + captures de référence | 0,5 j | Facile |
| 1 | Design system (tokens, `hp()`/`wp()`) | 1 j | Facile |
| 2 | Modèles + couche réseau + persistance | 1 j | Facile |
| 3 | WelcomeScreen + Lottie | 0,5 j | Facile |
| 4 | HomeScreen | 1,5 j | Moyenne |
| 5 | Grille maçonnerie | 2 j | **Difficile** |
| 6 | RecipeDetailsScreen + animations | 2 j | **Difficile** |
| 7 | Favoris, feuille de filtres, recherche | 1,5 j | Moyenne |
| 8 | Cache images + parité + régression visuelle | 2 j | Moyenne |
| 9 | Shipping (EAS, icônes, stores) | 1 j | Facile |

Soit **~2 semaines de travail effectif** pour une parité stricte. Les phases 5 et
6 pèsent à elles seules ~35 % du total.

---

## 1. Analyse du dépôt et des branches

### 1.1 Branches

| Branche | SHA | État |
| --- | --- | --- |
| `main` (locale) | `0b00ac9` | À jour, = `origin/main` |
| `origin/main` | `0b00ac9` | Merge PR #2 (`dev`) — **tout est consolidé** |
| `origin/dev` | `afb12f2` | Merge PR #1 (`feature/interactive-buttons`) — **entièrement fusionnée** |
| `origin/feature/interactive-buttons` | `59a3993` | **entièrement fusionnée** |

**Conclusion** : aucune branche en cours, aucune divergence —
`git diff origin/dev origin/main` est **vide**, l'arbre de travail est propre.
`dev` et `feature/interactive-buttons` ne sont plus que des pointeurs en retard
sur `main`. On peut démarrer la migration sur une branche neuve
(`feature/react-native`) sans risque de conflit, puis supprimer les anciennes.

### 1.2 Historique (du plus ancien au plus récent)

```
a1466e7  Reinitialisation git locale + rebrand FoodPad
7e36e24  Plan detail de migration React Native vers Swift/SwiftUI
b5be91b  Phases 0 et 1 : socle Xcode + design system SwiftUI
6bdb1ce  Phases 2 a 8 : app SwiftUI fonctionnelle, 3 ecrans operationnels
7bfbe75  Phase 9 : rendre chaque bouton actif, regenerer les visuels manquants
fb5cc8b  Supprimer l'app React Native, passer le repo en SwiftUI natif   ← bascule
a659017  Mise a jour du README.md
53940cc  Restructurer le projet a la racine et corriger la signature Xcode
7574131  Ajouter import Combine pour corriger la conformance ObservableObject
59a3993  .gitignore, project.pbxproj, FilterSheet.swift, xcsettings
afb12f2  (merge dev)
0b00ac9  (merge main)                                                     ← actuel
```

### 1.3 Le levier le plus important : le code RN d'origine est récupérable

Avant `fb5cc8b`, tout le code React Native était présent à la racine. Il est
donc **intégralement récupérable** :

```bash
# Lister l'ancienne arborescence RN
git ls-tree -r --name-only fb5cc8b^ | grep -E '^(src|App\.js|package\.json|utils)'

# Extraire n'importe quel fichier
git show fb5cc8b^:src/screens/HomeScreen.js
git show fb5cc8b^:src/components/RecipesCard.js
git show fb5cc8b^:utils/index.js
git show fb5cc8b^:package.json
```

Fichiers RN d'origine récupérables : `App.js`, `src/navigation/index.js`,
`src/screens/{Welcome,Home,RecipeDetails}Screen.js`,
`src/components/{Categories,Recipes,RecipesCard,Loading}.js`,
`src/constants/index.js`, `utils/index.js`, `tailwind.config.js`, et les assets
(`assets/images/{avatar,background}.png`, `assets/lottie/food-logo.json`).

> ⚠️ On s'en sert comme **référence d'idiomes RN**, pas comme point de départ :
> le code actuel (Swift) est plus riche (Favoris, filtres, recherche, cache
> disque, messages d'erreur). Le code cible doit reproduire **le Swift**, pas
> l'ancien RN.

### 1.4 Structure actuelle de l'app (Swift)

```
FoodPad/
├── FoodPadApp.swift              NavigationStack + routes (enum)
├── Theme/                        Color+Hex, Theme, Typography, Responsive (hp/wp)
├── Models/Models.swift           Meal, Category, Ingredient + décodage
├── Services/
│   ├── MealService.swift         protocole + LiveMealService (URLSession)
│   ├── MockMealService.swift     données hors ligne (previews/tests)
│   └── FavoritesStore.swift      persistance UserDefaults (clé v2)
├── Components/
│   ├── Components.swift          Loading, SearchBar, CategoryBar, HomeHeader, HomeHeadline, RecipesHeader
│   ├── RecipeCard.swift          carte + RecipesGrid
│   ├── MasonryGrid.swift         Layout maison (colonne la plus courte)
│   ├── FilterSheet.swift         RecipeFilter + feuille
│   ├── CachedImage.swift         cache mémoire + disque
│   ├── LottieLogoView.swift      Lottie (avec repli statique)
│   ├── Diagnostics.swift         rapport de debug (dev only)
│   └── DevTools.swift            seeds/route de lancement (Debug)
├── Screens/                      Welcome, Home, RecipeDetails, Favorites
├── DesignSystem/DesignSystemPreview.swift   écran-témoin des tokens
└── Assets.xcassets/              AccentColor, AppIcon, Avatar, Background
```

---

## 2. Inventaire de l'app à reproduire

C'est la **liste des écrans/comportements** que la version React Native devra
couvrir à l'identique.

### 2.1 Écrans

| Écran | Fichier source (Swift) | Contenu |
| --- | --- | --- |
| Welcome | `Screens/WelcomeScreen.swift` | Fond accent + image, logo Lottie, titre, sous-titre, bouton |
| Home | `Screens/HomeScreen.swift` | Header, titres, recherche, catégories, chip de filtre, grille |
| RecipeDetails | `Screens/RecipeDetailsScreen.swift` | Image héro, back/cœur, titre, liens, ingrédients, instructions |
| Favorites | `Screens/FavoritesScreen.swift` | Liste hors ligne des favoris + état vide + purge |
| Filters (sheet) | `Components/FilterSheet.swift` | Catégorie + « Favorites Only », Apply / Reset |

> **Le RN d'origine n'avait que 3 écrans.** La version cible doit en avoir 5
> (Favoris et filtres ont été ajoutés par la réécriture Swift). C'est une
> extension volontaire, pas une régression.

### 2.2 Navigation

- `Welcome` = route initiale (pas de header).
- `Welcome → Home → RecipeDetails`.
- `Home → Favorites → RecipeDetails`.
- Headers masqués, `tint` global = accent.
- Côté RN : `@react-navigation/native` + `native-stack`, `headerShown: false`,
  `initialRouteName: 'Welcome'`, `screenOptions={{ headerShown: false }}`.

### 2.3 API (inchangé)

| Endpoint | Usage | Appelé par |
| --- | --- | --- |
| `GET /categories.php` | Catégories | Home au démarrage |
| `GET /filter.php?c={cat}` | Recettes allégées d'une catégorie | Home |
| `GET /lookup.php?i={id}` | Fiche complète | RecipeDetails |
| `GET /search.php?s={q}` | Recherche texte | Home (debounce 400 ms) |

Base : `https://www.themealdb.com/api/json/v1/1/` — aucune clé.

### 2.4 Comportements fonctionnels à répliquer

- **Catégorie par défaut** : `"Beef"`.
- **Recherche debounce 400 ms** + annulation de la requête précédente.
- **Favoris persistés** (Swift le fait ; l'ancien RN non). Store clé `v2`,
  entrée = `{ id, name, thumbnailURL }`, ordre d'ajout conservé.
- **Filtre « favoris uniquement »** appliqué **localement** (pas de réseau).
- **Changement de catégorie** : vide la grille, rechargement réseau, vide la
  recherche.
- **États distincts** : *chargement*, *erreur réseau* (bannière), *filtre qui
  masque tout* (« No favorite in {cat} » + bouton « Show all »), *liste vide*.
- **Fiche détaillée** : évite le double appel `lookup.php` si déjà chargée,
  « enrichit » l'entrée favorite après chargement.
- **Liens externes** : YouTube via schéma `youtube://` avec repli web, sinon
  `Linking.openURL`.

---

## 3. Design system extrait — **le contrat pixel**

Tout ce qui suit est la **source de vérité**. Aucune valeur ne doit être
inventée : elle vient de `Theme/`, `Typography.swift`, `Responsive.swift` et des
modificateurs de mise en page.

### 3.1 Couleurs

| Token | Valeur | Usage |
| --- | --- | --- |
| `accent` | `#f64e32` | Fond Welcome, catégorie active, cœur, points ingrédients, boutons |
| `neutral500` | `#737373` | Origine du plat, icônes secondaires |
| `neutral600` | `#525252` | Compteur « N Recipes », spinner |
| `neutral700` | `#404040` | Titres détails, sections, instructions |
| `neutral800` | `#262626` | Titres Home, noms de catégories |
| `pillInactive` | `#000000` @ 10 % | Pastille catégorie inactive, chip de filtre |
| `cardPlaceholder` | `#000000` @ 5 % | Fond d'image en cours de chargement |
| `cardGradient` | `transparent → rgba(0,0,0,0.9)` | Dégradé bas de carte (vertical) |

### 3.2 Typographie (police système — SF sur iOS)

Toutes les tailles sont en `hp()`. Correspondance de graisse relevée :

| Token | Graisse | Taille | Tracking | Couleur |
| --- | --- | --- | --- | --- |
| `welcomeTitle` | heavy (800) | `5.hp()` | 4 | blanc |
| `welcomeSubtitle` | medium (500) | `2.5.hp()` | 2 | blanc |
| `welcomeButton` | medium (500) | `2.2.hp()` | 0 | accent |
| `homeHeadline` | bold (700) | `3.5.hp()` | 0 | neutral800 |
| `homeHeadlineAccent` | heavy (800) | `3.5.hp()` | 0 | neutral800 / accent |
| `searchPlaceholder` | regular (400) | `1.7.hp()` | 2 | neutral800 / gray |
| `categoryLabel` | regular (400) | `1.6.hp()` | 0 | neutral800 |
| `recipesCount` | semibold (600) | `2.hp()` | 0 | neutral600 |
| `recipeCardTitle` | semibold (600) | `2.2.hp()` | 0 | blanc |
| `detailMealName` | bold (700) | `3.hp()` | 0 | neutral700 |
| `detailArea` | medium (500) | `2.hp()` | 0 | neutral500 |
| `detailSectionTitle` | bold (700) | `2.5.hp()` | 0 | neutral700 |
| `ingredientName` | medium (500) | `1.7.hp()` | 0 | neutral800 |
| `ingredientMeasure` | heavy (800) | `1.7.hp()` | 0 | neutral700 |
| `instructions` | regular (400) | `1.7.hp()` | 0 | neutral700 |

### 3.3 Échelle `hp()` / `wp()`

`hp(n)` = **n % de la hauteur** de l'écran, `wp(n)` = **n % de la largeur**.
Valeurs de référence calculées sur **iPhone 15 Pro (393 × 852 pt)** :

| Expression | valeur @393×852 |
| --- | --- |
| `1.5.hp()` | 12,8 |
| `1.6.hp()` | 13,6 |
| `1.7.hp()` | 14,5 |
| `2.2.hp()` | 18,7 |
| `2.5.hp()` | 21,3 |
| `3.hp()` | 25,6 |
| `3.5.hp()` | 29,8 |
| `5.hp()` | 42,6 |
| `6.hp()` | 51,1 |
| `8.hp()` | 68,2 |
| `14.hp()` | 119,3 |
| `20.hp()` | 170,4 |
| `25.hp()` | 213,0 |
| `35.hp()` | 298,2 |
| `40.hp()` | 340,8 |
| `45.hp()` | 383,4 |
| `40.wp()` | 157,2 |

> ⚠️ Cette convention est **relative à la hauteur** : en paysage ou sur iPad,
> les valeurs explosent. On la réplique **à l'identique** pour la parité, et on
> traite le responsive comme un chantier séparé (voir §8).

### 3.4 Mise en page par écran (valeurs exactes)

**Welcome**
- `ZStack` : fond `accent` plein écran → image `Background` en `cover` → contenu.
- Colonne `spacing = 10.hp()`.
- Lottie : `40.wp()` × `40.hp()`.
- Titre/sous-titre : `spacing = 2.hp()`.
- Bouton : padding vertical `1.5.hp()`, horizontal `5.hp()`,
  rayon `1.5.hp()`, fond blanc, texte accent.
- Marge basse `5.hp()`, barre d'état claire.

**Home**
- Fond blanc, `ScrollView` ; contenu : padding horizontal **16**, haut **56 pt
  fixes**, bas **50 pt**, `spacing = 24`.
- **Header** : icône filtres `2.2.hp()` dans un cadre `5.hp()`, grise (accent si
  filtre actif) + point accent `6×6` décalé `(4,-2)` ; avatar `5.hp()` circulaire
  + badge compteur (capsule accent, texte 9 pt bold, `minWidth 14`, offset `(6,-6)`).
- **Titres** : deux lignes, `spacing = 2` ; mot « Love » en accent.
- **Recherche** : `spacing 10`, padding **6**, fond blanc, bordure noire **1 pt**,
  rayon **12** ; loupe dans un cercle blanc `3.hp()` (icône `1.6.hp()` bold grise) ;
  champ `1.7.hp()` tracking 2 ; bouton effacer `xmark.circle.fill`.
- **Catégories** : horizontal, `spacing 16`, padding horizontal **15** ;
  pastille `RoundedRectangle` rayon **12**, padding **6**, taille `6.hp()+12` ;
  image `6.hp()` en cercle ; label `1.6.hp()`.
- **Chip de filtre actif** : `spacing 8`, padding h **12** / v **8**, capsule
  `pillInactive`.
- **Grille** : `spacing 16` ; en-tête « N Recipes » `2.hp()` semibold ;
  2 colonnes, `spacing` vertical **16** ; hauteur carte = `index % 3 == 0` ?
  `25.hp()` : `35.hp()`.
- **Chargement** : `topPadding 80`, hauteur `30.hp()`.
- **Bannière d'erreur** : fond `neutral700`, rayon 12, texte 12, blanc.

**RecipeCard**
- Décalage droit `8` si `index % 2 == 0`, sinon `0`.
- Image `cardWidth × hauteur`, rayon **35** (`continuous`).
- Dégradé vertical, hauteur `20.hp()`, ancré en bas, coins bas arrondis **35**.
- Titre blanc `2.2.hp()` semibold, bas-gauche, largeur `80 %`, **tronqué au
  20ᵉ caractère + « … »** (pas un `numberOfLines`), padding gauche **8**,
  bas **28**.

**RecipeDetails**
- Image héro : largeur écran × `45.hp()`.
- Barre du haut : padding h **20**, haut `14.hp()` ; boutons circulaires blancs
  `4.hp()`, icône `2.hp()` bold (back = accent, cœur = accent/gris).
- Feuille : padding h **16**, haut `3.hp()`, fond blanc **rayon haut 50
  `continuous`**, **chevauche l'image de −46 pt**.
- Titre `3.hp()` bold / origine `2.hp()` medium, `spacing 2`.
- Bloc liens « Watch & Cook » : icône `2.hp()` dans un carré `3.hp()` rayon 10
  (fond = teinte @10 %), titre `1.7.hp()`, flèche `1.4.hp()`, padding **12**,
  fond `cardPlaceholder` rayon **16**.
- Ingrédients : point accent `1.5.hp()`, nom `1.7.hp()` medium, mesure `1.7.hp()`
  heavy, `spacing 8`, retrait gauche **12** ; bloc padding **16**.
- Instructions : titre `2.5.hp()` bold, corps `1.7.hp()` regular neutral700.
- Marge basse **30**.

**Favorites**
- Header : back circulaire `4.hp()` (chevron `2.hp()` bold accent), titre
  « My Favorites » `3.5.hp()` bold, corbeille `2.hp()`.
- État vide : cœur `8.hp()` light accent@35 %, titre `3.hp()` bold
  neutral700, texte `1.7.hp()` neutral500 centré (padding h **32**), bouton
  « Browse Recipes » (padding v `1.2.hp()` / h `4.hp()`, rayon `1.5.hp()`).
- Mêmes paddings que Home (16 / 56 / 50, spacing 24).

### 3.5 Formes

| Rayon | Où | Style Swift |
| --- | --- | --- |
| **35** | carte recette | `continuous` |
| **50** | haut de la fiche détaillée | `continuous` |
| **12** | barre de recherche, pastille catégorie | `continuous` |
| **16** | boutons liens | circulaire |
| **10** | carré d'icône de lien | circulaire |
| **1.5.hp()** | bouton Welcome / « Browse Recipes » | circulaire |

> 🔑 **Point critique pixel** : SwiftUI utilise `style: .continuous`
> (*squircle*, superellipse d'Apple). `borderRadius` de React Native dessine un
> arc **circulaire**. Pour retrouver exactement la même courbe sur iOS, il faut
> `borderCurve: 'continuous'` (supporté par RN ≥ 0.71, **iOS uniquement**).
> Sans ça, la différence est invisible à l'œil nu mais **mesurable** en diff de
> captures. Sur Android, la courbe reste circulaire (limite de la plateforme).

### 3.6 Animations

| Animation | Où | Réglage Swift | Équivalent RN |
| --- | --- | --- | --- |
| Logo Lottie | Welcome | boucle auto | `lottie-react-native` `autoPlay loop` |
| Entrées en cascade | Details | `spring(response: 0.7, dampingFraction: 0.7)` + délais `0.2 / 0.25 / 0.3 / 0.4` | Reanimated `FadeInDown` / `withSpring` |
| Enfoncement bouton | partout | scale `0.94`, opacité `0.85`, `easeOut 0.12 s` | `Pressable` + Reanimated |

> `dampingFraction` SwiftUI ≠ `damping` Reanimated. L'ancien RN utilisait
> `.duration(700).springify().damping(12)`. Il faudra **calibrer** (voir §9.1).

---

## 4. Stratégie pour un rendu pixel-perfect

### 4.1 Figer la référence avant d'écrire une ligne

1. Lancer l'app SwiftUI sur un **unique appareil de référence** (iPhone 15 Pro
   simulateur, portrait, contenu identique via `MockMealService`).
2. Capturer **tous les états** dans `docs/golden/` :
   Welcome, Home (chargé), Home (chargement), Home (erreur), Home (favoris),
   Home (recherche), Details (top), Details (ingrédients), Details (instructions),
   Favorites (rempli), Favorites (vide), Filters (sheet).
3. Ces PNG deviennent le **juge de paix**. Aucune phase n'est « finie » tant que
   le diff pixel n'est pas dans la tolérance (voir §4.4).

Côté Swift, on dispose déjà des captures dans `docs/`, mais elles sont
partielles : il faut **compléter** les états manquants avant de commencer.

### 4.2 Un seul fichier de tokens

Créer `src/theme/tokens.ts` — **seul endroit** où vivent couleurs, tailles,
rayons, espacements. Aucun composant ne code une valeur en dur.

```ts
// src/theme/tokens.ts  (extrait)
export const colors = {
  accent: '#f64e32',
  neutral500: '#737373',
  neutral600: '#525252',
  neutral700: '#404040',
  neutral800: '#262626',
  pillInactive: 'rgba(0,0,0,0.10)',
  cardPlaceholder: 'rgba(0,0,0,0.05)',
  gradient: ['transparent', 'rgba(0,0,0,0.9)'] as const,
};

export const radius = { card: 35, sheet: 50, search: 12, link: 16, icon: 10 };
export const weight = {
  regular: '400', medium: '500', semibold: '600',
  bold: '700', heavy: '800',
} as const;

// hp / wp : POURCENTAGE d'écran, comme react-native-responsive-screen
export const HP = (n: number) => (n / 100) * Dimensions.get('window').height;
export const WP = (n: number) => (n / 100) * Dimensions.get('window').width;
```

### 4.3 Le piège `Dimensions` / orientation

`react-native-responsive-screen` lit `Dimensions.get('window')`. Il faut gérer
`Dimensions.addEventListener('change', …)` pour rester synchrone avec le
comportement Swift (`ScreenMetrics` relit la taille à chaque appel). On
verrouille **portrait** (`app.json` → `"orientation": "portrait"`) car toute
l'app est calibrée portrait : cela **élimine** une classe entière d'écarts.

### 4.4 Régression visuelle automatisée

Chaîne recommandée :

1. **Maestro** (ou Detox) — lance l'app sur le simulateur, navigue jusqu'à chaque
   écran déterministe (données mockées), et déclenche
   `xcrun simctl io booted screenshot`.
2. **`odiff`** ou `pixelmatch` — compare la capture à `docs/golden/*.png` et
   produit un diff + pourcentage de pixels différents.
3. Seuil : **0 % sur les zones statiques** (Welcome, Home chargé, Details), et
   tolérance uniquement sur les zones animées / images réseau (voir §4.5).

Le dépôt contenait déjà `scripts/inspect-screenshot.py` et
`scripts/generate-assets.py` (récupérables via `git show fb5cc8b^:scripts/...`) :
base à réutiliser pour le comparateur.

### 4.5 Ce qui ne sera *jamais* strictement identique (et pourquoi c'est OK)

- **Images réseau** (TheMealDB) : mêmes URLs, mêmes octets, donc identiques —
  *à condition* d'afficher la même taille et le même `resizeMode`.
- **Polices** : SF sur iOS → identique. Sur **Android**, la police système est
  Roboto : le rendu **diffère**. Décision à trancher (§8) : exiger une police
  embarquée, ou assumer l'écart hors iOS.
- **Animations** : jamais figées à l'image ; on compare les **états finaux**.

---

## 5. Stack React Native recommandée

| Couche | Choix | Justification |
| --- | --- | --- |
| Base | **Expo** (SDK stable) + *New Architecture* | Build iOS/Android, EAS, OTA, DX |
| Langage | **TypeScript strict** | Le Swift est typé ; on garde l'avantage |
| Navigation | `@react-navigation/native` + `native-stack` | Équivalent de `NavigationStack` |
| Styles | **StyleSheet natif + tokens TS** | Maîtrise pixel ; NativeWind = couche en plus |
| Animations | `react-native-reanimated` | `FadeInDown`, `withSpring`, gestes |
| Dégradés | `expo-linear-gradient` | Dégradé des cartes |
| Images | `expo-image` (cache disque + `placeholder`) | Remplace le cache base64 + AsyncStorage |
| Lottie | `lottie-react-native` | Logo Welcome |
| Icônes | `@expo/vector-icons` (Ionicons) **ou** `react-native-svg` + SVG Heroicons | Fidélité : SVG exacts |
| État | **Zustand** (ou Context + `useReducer`) | Favoris + filtre, plus simple que Redux |
| Persistance | `@react-native-async-storage/async-storage` (JSON) ou `expo-secure-store` pour rien | Favoris `v2` |
| Safe areas | `react-native-safe-area-context` | Équivalent `ignoresSafeArea` |
| HTTP | `axios` ou `fetch` | 4 endpoints |
| Tests visuels | Maestro + `odiff` | §4.4 |

> **Pourquoi pas NativeWind ?** L'ancien RN l'utilisait. C'est pratique, mais
> pour du **pixel-perfect mesuré**, une couche de traduction
> config → styles ajoute des inconnues (arrondis, ordre de priorité). Des
> `StyleSheet` alimentés par des tokens typés sont plus prévisibles et
> **exactement** reproductibles. On peut réintroduire NativeWind plus tard sans
> toucher aux tokens.

---

## 6. Table de correspondance Swift → React Native

| Concept SwiftUI | React Native |
| --- | --- |
| `ZStack` | `<View style={{ position:'absolute' }}>` superposés / `StyleSheet.absoluteFill` |
| `VStack(spacing:)` | `<View style={{ flexDirection:'column', gap }}>` |
| `HStack(spacing:)` | `<View style={{ flexDirection:'row', gap, alignItems:'center' }}>` |
| `ScrollView` | `<ScrollView>` / `<FlatList>` |
| `Text` | `<Text>` |
| `TextField` | `<TextInput>` |
| `Button` / `PressableStyle` | `<Pressable>` + Reanimated (scale/opacity) |
| `Image(resizable).scaledToFill()` | `<Image resizeMode="cover" style={{ width, height }}>` |
| `clipShape(RoundedRectangle(35, .continuous))` | `style={{ borderRadius: 35, borderCurve: 'continuous', overflow:'hidden' }}` |
| `UnevenRoundedRectangle(top 50)` | `borderTopLeftRadius` / `borderTopRightRadius` (+ `borderCurve`) |
| `LinearGradient(top→bottom)` | `expo-linear-gradient` `start={{x:.5,y:0}} end={{x:.5,y:1}}` |
| `.tracking(n)` | `letterSpacing: n` |
| `.font(.system(size, weight))` | `fontSize` + `fontWeight` (SF sur iOS) |
| `CachedImage` (disque) | `expo-image` (`cachePolicy: 'disk'`, `placeholder`) |
| `LottieAnimationView` | `lottie-react-native` `<LottieView autoPlay loop />` |
| `NavigationStack` + `enum Route` | `createNativeStackNavigator` + `ParamList` typé |
| `.sheet` + `presentationDetents` | `<Modal>` / `@gorhom/bottom-sheet` |
| `.confirmationDialog` | `<Alert>` |
| `@MainActor ObservableObject` | store Zustand (actions async) |
| `.task {}` | `useEffect` **avec** deps / `useQuery` |
| `Task.sleep` (debounce) | `setTimeout` + `clearTimeout` (ou lodash.debounce) |
| `UserDefaults` | `AsyncStorage` |
| `enum Route.initialStack()` (dev) | `initialRouteName` paramétrable par env |
| `Layout` maison (MasonryGrid) | deux colonnes calculées (voir §7, Phase 5) |
| `openURL` / `youtube://` | `Linking.canOpenURL` + `Linking.openURL` |

---

## 7. Phases de travail

### Phase 0 — Socle et référence

- [ ] Brancher `feature/react-native` depuis `main`.
- [ ] Restaurer les assets depuis l'historique :
      `assets/images/{avatar,background}.png`, `assets/lottie/food-logo.json`,
      `assets/{icon,splash}.png`.
- [ ] `npx create-expo-app foodpad-rn --template blank-typescript`.
- [ ] Activer *New Architecture* (`newArchEnabled: true`).
- [ ] Verrouiller `"orientation": "portrait"`.
- [ ] Installer la stack du §5.
- [ ] **Capturer les golden screenshots** de l'app Swift (§4.1) → `docs/golden/`.
- [ ] Écrire le script `scripts/compare-screenshots.ts` (`odiff` ou `pixelmatch`).

**Point de contrôle** : l'app vide se lance sur iPhone 15 Pro, et le script de
diff tourne (même s'il compare deux images identiques).

### Phase 1 — Design system

- [ ] `src/theme/tokens.ts` : toutes les valeurs du §3.
- [ ] `src/theme/typography.ts` : les 15 styles du §3.2 (fontSize/weight/letterSpacing).
- [ ] `src/theme/hp.ts` : `hp()` / `wp()` + écoute `Dimensions`.
- [ ] `src/components/Pressable.tsx` : équivalent `PressableStyle` (scale 0.94,
      opacity 0.85, 0.12 s) via Reanimated.
- [ ] Écran-témoin `DevTheme` reproduisant `DesignSystemPreview` (couleurs,
      typo, échelle `hp()`, formes).
- [ ] Diff du DevTheme contre le DesignSystemPreview Swift.

**Point de contrôle** : le DevTheme est pixel-identique au design system Swift.

### Phase 2 — Données

- [ ] `src/types.ts` : `Meal`, `Category`, `Ingredient`, `RecipeFilter`.
- [ ] `src/services/mealsApi.ts` : 4 endpoints, typés, gestion d'erreur.
- [ ] `src/services/mockMeals.ts` : mêmes données que `MockMealService`.
- [ ] `src/store/favoritesStore.ts` : persistance `v2` (`{id,name,thumbnailURL}`),
      ordre d'ajout, `toggle`, `enrich`, `removeAll`.
- [ ] `src/store/homeStore.ts` : catégories, recettes, catégorie active,
      recherche, `favoritesOnly`, états de chargement/erreur.
- [ ] Répliquer les règles fonctionnelles du §2.4.

### Phase 3 — WelcomeScreen

- [ ] Fond accent plein écran + `background.png` en `cover`.
- [ ] Lottie `40.wp() × 40.hp()`, `autoPlay loop`.
- [ ] Titre `5.hp()` heavy + `letterSpacing 4`, sous-titre `2.5.hp()` medium.
- [ ] Espacements `10.hp()` / `2.hp()`.
- [ ] Bouton blanc (rayon `1.5.hp()`), texte accent `2.2.hp()`, marge basse `5.hp()`.
- [ ] Barre d'état claire (`expo-status-bar`).
- [ ] `navigation.navigate('Home')`.

### Phase 4 — HomeScreen

- [ ] `ScrollView` : padding h 16, haut 56, bas 50, `gap 24`.
- [ ] `HomeHeader` : filtres + point actif, avatar + badge compteur.
- [ ] `HomeHeadline` : « Food You **Love** » (deux `<Text>` imbriqués).
- [ ] `SearchBar` : bordure noire 1 pt, rayon 12, loupe cerclée, champ tracking 2,
      bouton effacer.
- [ ] `CategoryBar` : horizontal, `gap 16`, padding h 15, pastilles rayon 12 /
      image `6.hp()` cercle, active en accent.
- [ ] Chip « Favorites Only » refermable.
- [ ] Bannière d'erreur.
- [ ] États : chargement (`topPadding 80`, hauteur `30.hp()`), vide, filtre vide.

### Phase 5 — Grille maçonnerie ⚠️

**Décision d'architecture** : les hauteurs de carte sont **fixes et
indépendantes du contenu** (`index % 3 == 0 ? 25.hp() : 35.hp()`). On peut donc
calculer les positions **de façon déterministe**, exactement comme le fait
`RecipesGrid.gridHeight` côté Swift.

- [ ] `splitColumns(meals)` : répartit les index dans 2 colonnes selon la règle
      « colonne la plus courte, égalité → gauche » (réplique de `shortestColumn`).
- [ ] Rendu : une `View` parent en `flexDirection: 'row'`, deux colonnes
      `flex: 1`, `gap 16`, chaque carte avec sa hauteur exacte.
- [ ] `RecipeCard` :
      - [ ] décalage droit `8` si `index % 2 == 0` ;
      - [ ] image rayon `35` + `borderCurve: 'continuous'` ;
      - [ ] dégradé `20.hp()` ancré en bas, coins bas 35 ;
      - [ ] titre tronqué **au 20ᵉ caractère** (`name.length > 20 ? name.slice(0,20)+'…' : name`),
            largeur 80 %, padding gauche 8, bas 28 ;
      - [ ] placeholder `cardPlaceholder`.
- [ ] En-tête « N Recipes » masqué pendant la recherche (comme le Swift).
- [ ] Diff contre `docs/golden/home.png`.

> Ne **pas** réutiliser `@react-native-seoul/masonry-list` : son algorithme de
> placement peut différer d'un cran. Le calcul déterministe garantit la parité
> et reste performant (hauteurs fixes).

### Phase 6 — RecipeDetailsScreen + animations

- [ ] Image héro écran × `45.hp()`, `expo-image` (cache).
- [ ] Barre du haut flottante : back + cœur circulaires `4.hp()`.
- [ ] Feuille blanche : `borderTopLeftRadius/RightRadius 50` +
      `borderCurve: 'continuous'`, `marginTop: -46` (chevauchement).
- [ ] Titre / origine, bloc liens « Watch & Cook », ingrédients (points accent
      `1.5.hp()`, nom medium, mesure heavy), instructions.
- [ ] Cascade d'entrées : Reanimated `FadeInDown` délayé `200/250/300/400 ms`,
      spring calibré (§9.1).
- [ ] Liens externes : `Linking`, repli `youtube://` → web.
- [ ] Chargement : spinner `topPadding 64`, hauteur `20.hp()`.

### Phase 7 — Favoris, filtres, recherche

- [ ] `FavoritesScreen` : header (back / titre / corbeille), grille réutilisée,
      état vide (cœur `8.hp()`, textes, bouton).
- [ ] `Alert` de confirmation de purge.
- [ ] `FilterSheet` : catégorie + toggle « Favorites Only », Apply / Reset,
      deux crans (`medium` / `large`), `tint` accent.
- [ ] Recherche : debounce 400 ms + annulation, masque l'en-tête de compteur.
- [ ] Application du filtre sans réseau ; message « No favorite in {cat} » +
      « Show all ».

### Phase 8 — Cache, parité, régression

- [ ] `expo-image` avec `cachePolicy: 'disk'` sur toutes les images distantes.
- [ ] Parité des 3 états (chargement / erreur / contenu) sur chaque écran.
- [ ] Lancer Maestro sur chaque écran déterministe → diff `odiff` → corriger.
- [ ] Tester iPhone SE (3ᵉ gén.), iPhone 15 Pro, et (décision §8) Android.
- [ ] Documenter les écarts **assumés** (Android, animations).

### Phase 9 — Shipping

- [ ] Icône 1024×1024 **sans alpha** + `splash.png` (`expo-splash-screen`).
- [ ] `app.json` : `bundleIdentifier` / `package`, version.
- [ ] Build EAS (iOS + Android).
- [ ] TestFlight / Test interne Google Play.

---

## 8. Décisions à trancher **avant de coder**

| # | Décision | Recommandation | Raison |
| --- | --- | --- | --- |
| 1 | Expo ou React Native « bare » ? | **Expo** | EAS, OTA, DX ; sortie possible plus tard |
| 2 | TypeScript ou JS ? | **TypeScript strict** | Le Swift est typé ; on ne perd rien |
| 3 | Styles : StyleSheet ou NativeWind ? | **StyleSheet + tokens** | Prévisibilité pixel ; NativeWind = couche en plus |
| 4 | Appareil de référence ? | **iPhone 15 Pro, portrait** | Un seul juge de paix pour le diff |
| 5 | Police sur Android ? | **Embarquer SF-like** (ex. Inter) *ou* assurer l'écart | Sinon Roboto ≠ SF |
| 6 | `borderCurve: 'continuous'` ? | **Oui sur iOS** | Sinon squircles ≠ cercles |
| 7 | Grille : lib ou calcul maison ? | **Calcul maison déterministe** | Parité exacte, zéro dépendance |
| 8 | Favoris : reproduire le bug RN ? | **Non, garder la persistance** | Le Swift corrige déjà le défaut |
| 9 | Localisation ? | **Anglais** d'abord | L'UI actuelle est en anglais |
| 10 | Date de bascule (supprimer le Swift) ? | **Après parité validée**, pas avant | Garder la référence tant qu'on en a besoin |

---

## 9. Pièges connus

### 9.1 Le ressort d'entrée n'a pas d'équivalent exact

`spring(response: 0.7, dampingFraction: 0.7)` (SwiftUI) et
`.duration(700).springify().damping(12)` (Reanimated) décrivent des
physiques différentes. **À calibrer au visuel** : partir de
`withSpring({ damping: 12, stiffness: 90, mass: 1 })` et ajuster entre
`damping 8` (sec) et `14` (mou). Comparer les états **finaux**, pas le mouvement.

### 9.2 `borderCurve` : le détail qui trahit

SwiftUI arrondit « en continu » (squircle). Sans `borderCurve: 'continuous'`
(ou en oubliant le `overflow: 'hidden'` qui va avec), le diff pixel révèle
l'écart. Ne pas l'oublier sur : carte (35), feuille (50), recherche (12),
pastille (12).

### 9.3 `hp()` figé au premier rendu

`Dimensions.get('window')` est lu une fois si on ne s'abonne pas. Résultat :
après rotation ou changement de taille (split-view iPad), l'UI ne suit pas.
S'abonner à l'événement `change`, même si on verrouille portrait.

### 9.4 L'ombre et les `elevation` involontaires

Aucun écran Swift n'a d'ombre, mais React Native Android ajoute une `elevation`
par défaut sur certains composants. Vérifier `elevation: 0` / `shadowOpacity: 0`
là où le Swift est plat (cartes, feuille, boutons).

### 9.5 Le tronquage à 20 caractères est **manuel**

C'est une coupe au caractère + « … », pas un `numberOfLines={1}`. Un
`numberOfLines` s'adapte à la largeur → rendu différent. Répliquer
`name.slice(0, 20)`.

### 9.6 `fontWeight` numérique vs nommé

Utiliser les valeurs numériques du §3.2 (`'800'` pour heavy, `'700'` bold…).
`'heavy'` / `'black'` peuvent se résoudre différemment selon la plateforme.

### 9.7 En-tête cliqué sous la `StatusBar`

Le Home Swift laisse le contenu **passer sous la barre d'état** (padding haut
fixe 56). Avec `SafeAreaView`, RN pousserait le contenu vers le bas → décalage.
Utiliser un `<View>` simple + padding 56, comme le Swift, pas un
`SafeAreaView` pour le contenu.

### 9.8 Ne pas porter les anti-patterns de l'ancien RN

- Favoris dans `useState` seulement (perte au redémarrage).
- `useEffect` sans tableau de dépendances (appel réseau à chaque rendu).
- Cache d'images en base64 dans `AsyncStorage`.
- Import d'un module interne de React Native (`TurboModuleRegistry`).

Ces défauts sont déjà corrigés dans le Swift ; la cible RN doit rester corrigée.

---

## 10. Checklist de parité visuelle (écran par écran)

**Welcome**
- [ ] Fond accent + image en cover
- [ ] Logo Lottie 40 % × 40 %, centré, en boucle
- [ ] Titre blanc heavy très espacé (tracking 4)
- [ ] Bouton blanc, texte accent, rayon `1.5.hp()`
- [ ] Barre d'état claire

**Home**
- [ ] Filtres (gauche) et avatar (droite) alignés, badge compteur
- [ ] « Food You » noir / « Love » accent
- [ ] Recherche : bordure noire 1 pt, rayon 12, loupe cerclée
- [ ] Catégorie active accent, inactives noir 10 %
- [ ] 2 colonnes alignées en haut, hauteurs alternées (25 % / 35 %)
- [ ] Dégradé noir bas `20.hp()`, coins bas 35
- [ ] Titre blanc tronqué à 20 caractères
- [ ] En-tête « N Recipes » masqué en recherche

**Details**
- [ ] Image plein largeur, `45.hp()`
- [ ] Back (accent) et cœur bien visibles sur l'image
- [ ] Feuille blanche rayon 50 **chevauchant** l'image de 46 pt
- [ ] Ingrédients : points rouges `1.5.hp()` alignés
- [ ] Mesure en heavy, nom en medium
- [ ] Cascade d'apparition (3 blocs)

**Favoris**
- [ ] État plein = grille ; état vide = cœur + textes + bouton
- [ ] Bouton corbeille uniquement si non vide
- [ ] Persistance après redémarrage

**Filtres**
- [ ] Deux crans (`medium` / `large`)
- [ ] Apply applique sans réseau ; Reset remet à zéro
- [ ] Toggle et coche en accent

---

## 11. Ordre d'exécution recommandé

1. **Phase 0 + 1** — socle + tokens + écran-témoin. *Point de contrôle* : le
   DevTheme est au pixel près.
2. **Phase 2** — données + persistance. Vérifier avec l'API réelle.
3. **Phase 3 + 4** — Welcome + Home. L'app est navigable.
4. **Phase 5** — la grille. C'est le point dur, prendre le temps.
5. **Phase 6** — détails + animations (spinner puis cascade).
6. **Phase 7** — favoris, filtres, recherche.
7. **Phase 8** — cache + régression visuelle automatisée ; corriger les écarts.
8. **Phase 9** — shipping.
9. **Bascule** — seulement une fois la parité validée, archiver l'app Swift
   (ne pas supprimer l'historique : il reste la référence).

> **Conseil** : avancer écran par écran, avec un diff pixel après chaque écran.
> Une parité « presque » accumulée sur cinq écrans coûte plus cher à rattraper
> qu'un diff systématique.

---

## 12. Suivi

| Phase | Statut | Date | Commentaire |
| --- | --- | --- | --- |
| 0 — Socle + golden screenshots | ⬜ À faire | | |
| 1 — Design system | ⬜ À faire | | |
| 2 — Données + persistance | ⬜ À faire | | |
| 3 — Welcome | ⬜ À faire | | |
| 4 — Home | ⬜ À faire | | |
| 5 — Grille maçonnerie | ⬜ À faire | | |
| 6 — Détails + animations | ⬜ À faire | | |
| 7 — Favoris / filtres / recherche | ⬜ À faire | | |
| 8 — Cache + régression visuelle | ⬜ À faire | | |
| 9 — Shipping | ⬜ À faire | | |

---

## Annexe A — Récupérer le code React Native d'origine

```bash
# Arborescence complète avant la bascule vers Swift
git ls-tree -r --name-only fb5cc8b^

# Fichiers utiles
git show fb5cc8b^:package.json
git show fb5cc8b^:src/screens/HomeScreen.js
git show fb5cc8b^:src/screens/WelcomeScreen.js
git show fb5cc8b^:src/screens/RecipeDetailsScreen.js
git show fb5cc8b^:src/components/Categories.js
git show fb5cc8b^:src/components/Recipes.js
git show fb5cc8b^:src/components/RecipesCard.js
git show fb5cc8b^:src/components/Loading.js
git show fb5cc8b^:src/navigation/index.js
git show fb5cc8b^:utils/index.js
git show fb5cc8b^:tailwind.config.js
git show fb5cc8b^:scripts/inspect-screenshot.py
git show fb5cc8b^:scripts/generate-assets.py

# Extraire un dossier entier
git checkout fb5cc8b^ -- src/ utils/ assets/   # puis adapter, ne pas garder tel quel
```

## Annexe B — Récupérer les médias

```bash
mkdir -p /tmp/foodpad-assets
for f in assets/images/avatar.png assets/images/background.png \
         assets/lottie/food-logo.json assets/icon.png assets/splash.png; do
  git show "fb5cc8b^:$f" > "/tmp/foodpad-assets/$(basename "$f")"
done
```
