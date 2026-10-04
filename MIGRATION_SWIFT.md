# Plan de migration : React Native → Swift / SwiftUI

> **Statut** : plan de travail
> **Source** : app React Native 0.72 / Expo SDK 49 (dossier `src/`)
> **Cible** : iOS natif, SwiftUI (iOS 16+), repli UIKit si nécessaire
> **Objectif** : rendu visuel et comportement identiques à l'app actuelle

---

## 0. Ce qui va réellement se passer

Il faut être clair sur un point : **ce n'est pas un portage, c'est une réécriture.**
~700 lignes de JavaScript à traduire ligne par ligne en Swift. Aucun pixel n'est
gratuit — chaque taille, chaque couleur, chaque animation doit être relevée puis
rejouée à la main.

Ce que la migration **gagne** : animations à 60/120 fps natives, accès aux
APIs iOS, pas de couche de pont JS, taille d'app réduite, store-ready.
Ce qu'elle **coûte** : 4 à 6 semaines de travail effectif.

**Charge estimée par phase** (à ajuster selon ton expérience SwiftUI) :

| Phase | Contenu | Charge | Difficulté |
| --- | --- | --- | --- |
| 0 | Socle projet Xcode | 1 j | Facile |
| 1 | Design system | 0,5 j | Facile |
| 2 | Modèle + réseau | 1 j | Facile |
| 3 | WelcomeScreen | 0,5 j | Facile |
| 4 | HomeScreen | 1,5 j | Moyenne |
| 5 | Grille maçonnerie | 3 j | **Difficile** |
| 6 | RecipeDetailsScreen | 2 j | **Difficile** |
| 7 | Cache + finitions | 1 j | Moyenne |
| 8 | Shipping | 0,5 j | Facile |

Les phases 5 et 6 représentent ~40 % du total. Ne les underestimate pas.

---

## 1. Inventaire de l'app à reproduire

Relevé fait sur le code source. C'est ta référence de comparaison visuelle.

### Écrans

| Écran | Fichier RN | Contenu |
| --- | --- | --- |
| Welcome | `src/screens/WelcomeScreen.js` | Fond image, logo Lottie, titre, sous-titre, bouton |
| Home | `src/screens/HomeScreen.js` | Avatar, filtres, titres, recherche, catégories, grille |
| RecipeDetails | `src/screens/RecipeDetailsScreen.js` | Image HD, favori, ingrédients, instructions |

### Composants

| Composant | Fichier RN | Rôle |
| --- | --- | --- |
| `Categories` | `src/components/Categories.js` | Barre horizontale de catégories |
| `Recipes` | `src/components/Recipes.js` | En-tête + conteneur de grille |
| `RecipesCard` | `src/components/RecipesCard.js` | Carte avec image + dégradé + titre |
| `Loading` | `src/components/Loading.js` | `ActivityIndicator` centré |
| `CachedImage` | `utils/index.js` | Cache base64 des images |

### Animations

| Anim | Où | Réglages |
| --- | --- | --- |
| Lottie logo | Welcome | `autoPlay`, 1080×1080, 25 fps, 6 layers |
| `FadeInDown` | RecipeDetails | 3 entrées, délais 200 / 300 / 400 ms |
| Spring | RecipeDetails | `.duration(700).springify().damping(12)` |
| Shared transition | Home → Details | `sharedTransitionTag` sur l'image |

### API

| Endpoint | Usage |
| --- | --- |
| `GET /api/json/v1/1/categories.php` | Liste des catégories |
| `GET /api/json/v1/1/filter.php?c={catégorie}` | Recettes filtrées |
| `GET /api/json/v1/1/lookup.php?i={id}` | Détail d'une recette |

Base : `https://www.themealdb.com` — aucune clé API requise.

---

## 2. Design system à extraire

### Couleurs

| Token RN | Hex | Usage Swift |
| --- | --- | --- |
| accent | `#f64e32` | Welcome fond, boutons actifs, cœur favori, points ingrédients |
| `neutral-500` | `#737373` | Zone du plat (sous-titre détails) |
| `neutral-600` | `#525252` | Compteur de recettes |
| `neutral-700` | `#404040` | Titres détails, sections |
| `neutral-800` | `#262626` | Titres accueil, noms catégories |
| inactive pill | `black/10` | Catégorie non sélectionnée |
| card placeholder | `black/5` | Fond pendant chargement image |
| gradient top | `transparent` | Dégradé carte |
| gradient bottom | `rgba(0,0,0,0.9)` | Dégradé carte |

> ⚠️ Ce sont les valeurs **Tailwind v3 par défaut**. Vérifie-les dans le
> rendu réel avant de les figer — si le projet n'a pas surchargé `theme`,
> celles-ci sont correctes.

### Typographie

L'app utilise la police système (San Francisco sur iOS) — **rien à embarquer**.
Seules les graisses et tailles comptent :

| Élément | Graisse | Taille |
| --- | --- | --- |
| Titre Welcome | extrabold + tracking large | `hp(5)` |
| Sous-titre Welcome | medium + tracking | `hp(2.5)` |
| Titre Home L1 | bold | `hp(3.5)` |
| Titre Home L2 | extrabold | `hp(3.5)` |
| Placeholder recherche | default | `hp(1.7)` |
| Label catégorie | default | `hp(1.6)` |
| Titre recette carte | semibold | `hp(2.2)` |
| Compteur recettes | semibold | `hp(2)` |
| Nom recette détails | bold | `hp(3)` |
| Origine détails | medium | `hp(2)` |
| Titre section détails | bold | `hp(2.5)` |
| Ingrédient nom | medium | `hp(1.7)` |
| Ingrédient mesure | extrabold | `hp(1.7)` |
| Instructions | default | `hp(1.7)` |

### 🔑 `hp()` / `wp()` — la décision la plus structurante

L'app utilise `react-native-responsive-screen` :
`hp(n)` = `n % de la hauteur de l'écran`, `wp(n)` = `n % de la largeur`.

**Cette approche est une aberration responsive.** Sur iPad (ratio 4:3) ou en
paysage, elle produit une mise en page illisible — l'app est calibrée pour un
téléphone en portrait.

Deux options, à trancher **avant** d'écrire la première vue :

**Option A — répliquer à l'identique (recommandé pour la migration)**
```swift
extension CGFloat {
    /// Équivalent exact de heightPercentageToDP(n) : n % de la hauteur d'écran
    func hp() -> CGFloat { self / 100 * UIScreen.main.bounds.height }
}
extension CGFloat {
    func wp() -> CGFloat { self / 100 * UIScreen.main.bounds.width }
}
```
Garantit un rendu identique. Reproduit le défaut.

**Option B — migrer vers un vrai système responsive**
Convertir les valeurs en `@ScaledMetric`, en guides de mise en page SwiftUI, ou
enconstraintes avec priorities de compression. Rendu plus propre sur iPad,
mais **différent** de l'app actuelle sur les petits écrans.

👉 **Recommandation** : Option A pour la migration, puis bascule progressive vers
B dans une phase ultérieure. Ne jamais mélanger les deux dans une même vue.

### Assets

| Fichier | Dimensions | Destination Xcode |
| --- | --- | --- |
| `assets/icon.png` | 1024×1024 | AppIcon (transparence à retirer — iOS la refuse) |
| `assets/adaptive-icon.png` | 1024×1024 | Non utilisé sur iOS |
| `assets/splash.png` | 1284×2778 | LaunchScreen |
| `assets/favicon.png` | 48×48 | Non utilisé sur iOS |
| `assets/images/avatar.png` | 2084×3126 | ImageSet "avatar" |
| `assets/images/background.png` | 2084×3126 | ImageSet "background" |
| `assets/lottie/food-logo.json` | 1080×1080, 25 fps, 6 layers | Ressource Lottie |

> Les images de fond sont à 3× — parfait pour iOS, ne pas réduire.

---

## 3. Phases de travail

### Phase 0 — Socle projet

- [ ] Créer `FoodPad.xcodeproj` : SwiftUI App, **iOS 16.0+**, Swift 5.9
- [ ] Dépendances SPM :
      - [Lottie](https://github.com/airbnb/lottie-ios) (MIT)
      - Heroicons (SVG officiels) ou SF Symbols — voir ci-dessous
- [ ] *Target → General → Identity* : bundle ID `com.armelbogue.foodpad`
- [ ] Importer les 5 assets dans un catalogue `Assets.xcassets`
- [ ] Créer `Theme/` (couleurs, typo, `hp()`), `Models/`, `Services/`, `Screens/`, `Components/`
- [ ] `App.swift` avec `NavigationStack`

**Icônes :** Heroicons a des sets SVG officiels et Apple en publie des versions
compatibles SF Symbols. Pour une fidélité maximale, importer les SVG Heroicons
comme templates. SF Symbols `chevron.left` / `heart` (variante `.fill`) sont un
substitut acceptable — **valide le rendu avant d'aller plus loin.**

### Phase 1 — Design system

- [ ] `Color+Hex.swift` : initialiseur depuis hex + opacité
- [ ] `Theme.swift` : toutes les couleurs de la table §2
- [ ] `Typography.swift` : extension `Font` avec les graisses/listings
- [ ] `Responsive.swift` : `hp()` / `wp()` (Option A)
- [ ] Créer un **SwiftUI Preview** avec une maquette regroupant tous les tokens
      → c'est ta référence visuelle pour le reste du travail

### Phase 2 — Modèle & réseau

- [ ] `Meal.swift` : `struct Meal: Decodable, Identifiable`
- [ ] ⚠️ **20 champs d'ingrédients optionnels** — `strIngredient1...20` et
      `strMeasure1...20`. L'API renvoie toujours 20 clés, souvent vides.
      Ne pas les faire `String` non-optionnels.
- [ ] `Category.swift`
- [ ] `MealService.swift` : les 3 endpoints en `async/await`
- [ ] `enum AppError: Error` pour les cas d'échec réseau
- [ ] Gérer l'état : `@Observable` (iOS 17) ou `ObservableObject` (iOS 16).
      **iOS 16 → reste sur `ObservableObject` + `@Published`** pour ne pas
      relevé la cible.
- [ ] Prévoir un `MockMealService` pour developper l'UI sans réseau

### Phase 3 — WelcomeScreen

- [ ] `ZStack` : image de fond en `.fill` / `.resizeAspectFill`, plein écran
- [ ] `LottieView` en `wp(40) × hp(40)`, `autoPlay`
- [ ] Titre `.extrabold`, `hp(5)`, blanc, `.tracking(4)` (l'espacement large de l'app)
- [ ] Sous-titre `.medium`, `hp(2.5)`, blanc
- [ ] Bouton blanc : padding vertical `hp(1.5)`, horizontal `hp(5)`,
      radius `hp(1.5)`, texte accent `hp(2.2)`
- [ ] `navigationDestination` vers Home

### Phase 4 — HomeScreen

- [ ] `ScrollView` + `padding(.top, hp(14))`, `spacing` 6 entre les blocs
- [ ] En-tête : icône filtres à gauche (`hp(4)`, gris), avatar圆形 à droite
      (`hp(5)`, bordure ronde) — les deux sont sur la même ligne
- [ ] Deux lignes de titre : `bold` puis `extrabold`, avec le mot « Love »
      coloré en accent via un `Text` imbriqué
- [ ] Barre de recherche : `RoundedRectangle(cornerRadius: 12)` + `stroke`,
      padding 6, loupe dans un cercle blanc à gauche, `TextField` à droite
- [ ] `CategoryBar` : `ScrollView(.horizontal)`, `spacing 16`,
      `padding(.horizontal, 15)`, indicateur masqué
      - [ ] Pastille : `RoundedRectangle(12)` + padding 6,
            image `hp(6) × hp(6)` en cercle, fond accent si actif sinon `black/10`
      - [ ] Label sous la pastille : `hp(1.6)`, `neutral-800`
- [ ] `RecipesHeader` : compteur `hp(2)`, `neutral-600`

### Phase 5 — Grille en maçonnerie ⚠️

**Phase la plus difficile.** MasonryList (RN) n'a pas d'équivalent natif.

- [ ] Implémenter un `Layout` SwiftUI conforme à `Layout` (iOS 16+) :
      - 2 colonnes de largeur égale
      - placement de chaque élément dans la **colonne la plus courte**
      - hauteur mesurée via le `cache` de `LayoutValueKey`
- [ ] Alternative : paquet SPM tiers (attention à la maintenance — vérifier les
      issues ouvertes avant d'en choisir un)
- [ ] Répliquer **exactement** la logique de hauteur de l'app :
      ```swift
      // index % 3 == 0 → hauteur courte, sinon longue
      let cardHeight = index % 3 == 0 ? 25.hp() : 35.hp()
      ```
      ⚠️ Cette règle arbitraire produit des hauteurs décorrélées de la longueur
      du nom. La reproduire pour l'identité ; c'est aussi le premier endroit où
      tu pourras améliorer le design plus tard.
- [ ] `RecipeCard` :
      - [ ] Image `width: 100%`, rayon **35 points** (valeur fixe, pas adaptative)
      - [ ] Padding droit 8 sur les cartes d'indice **pair**
      - [ ] Dégradé vertical sur `hp(20)` de hauteur, coins bas arrondis 35
      - [ ] Titre `hp(2.2)`, blanc, en bas à gauche, largeur max 80 %
            → **tronqué à 20 caractères + `...`**
- [ ] Marquer les cas où le nom ≤ 20 caractères (pas d'ellipse)

### Phase 6 — RecipeDetailsScreen

- [ ] Image HD : `width 100%`, `height hp(45)`
- [ ] Boutons retour / cœur superposés en absolu sur l'image, circulaires blancs,
      marges 5, icônes `hp(3.5)`, cœur accenté si favori
- [ ] Contenu en surface blanche, **coins hauts arrondis 50**, reposant sur
      l'image avec un chevauchement de `-46` (`.offset(y: -46)`)
- [ ] Pendant le chargement : spinner centré avec marge haute 16
- [ ] Nom `bold hp(3)`, origine `medium hp(2)`
- [ ] Liste d'ingrédients en `LazyVStack` :
      - [ ] point accent circulaire `hp(1.5) × hp(1.5)`
      - [ ] nom `medium hp(1.7)` + mesure `extrabold hp(1.7)`
      - [ ] espacement vertical 2
- [ ] Instructions : texte `hp(1.7)`, `neutral-700`
- [ ] Animations d'entrée : 3 `.transition(.move(edge: .bottom).combined(with: .opacity))`
      avec `delay(0.2 / 0.3 / 0.4)` et `.spring(response: 0.7, dampingFraction: 0.7)`
      - [ ] Vérifier visuellement : `damping(12)` de Reanimated n'a pas
            d'équivalent exact en SwiftUI. Si l'animation est trop « molle »
            ou trop « sèche », ajuste `dampingFraction` entre 0.6 et 0.9.

### Phase 7 — Cache & finitions

- [ ] `CachedImage` : télécharger l'image, encoder en base64, stocker sur disque
- [ ] ⚠️ **Utiliser `FileManager` (documents), pas `UserDefaults`** — des images
      base64 dans UserDefaults est un anti-pattern connu (performance, limites)
- [ ] Clé de cache = URL de l'image (comme le fait l'app RN)
- [ ] Gestion d'erreur : fallback sur l'URL distante si le décodage échoue
- [ ] Tests sur **iPhone SE (3e gen)** et **iPhone 15 Pro Max**
      → avec `hp()` relatif, les deux rendus divergent beaucoup. Compare
      ligne par ligne avec l'app RN.
- [ ] Vérifier les 3 états : chargement, erreur réseau, contenu

### Phase 8 — Shipping

- [ ] Icône 1024×1024 **sans canal alpha** (iOS rejette les PNG transparents)
- [ ] LaunchScreen avec `splash.png`
- [ ] Versioning + build configuration
- [ ] TestFlight pour validation sur appareil réel

---

## 4. Décisions à trancher

| # | Décision | Recommandation | Pourquoi |
| --- | --- | --- | --- |
| 1 | `hp()` ou responsive natif ? | **Répliquer `hp()`** d'abord | Garantit l'identité visuelle ; migration du layout dans une phase séparée |
| 2 | Version d'iOS cible | **16.0** | `Layout` + `NavigationStack` disponibles |
| 3 | `@Observable` ou `ObservableObject` ? | **`ObservableObject`** | `@Observable` exige iOS 17 |
| 4 | Heroicons ou SF Symbols ? | **Heroicons SVG** | Fidélité au design ; SF Symbols = compromis |
| 5 | Grille : `Layout` maison ou paquet SPM ? | **`Layout` maison** | 100 % de contrôle sur la règle de placement, pas de dépendance à maintenir |
| 6 | Persister les favoris ? | **Oui, `UserDefaults`** | ⚠️ L'app RN ne le fait **pas** — le cœur se perd à chaque relance. See ci-dessous |
| 7 | Langue de l'UI | **Anglais** pour l'instant | L'app RN est en anglais ; la localisation FR est une phase séparée |

---

## 5. Pièges connus

### 5.1 Le `FadeInDown` de Reanimated n'a pas d'équivalent exact

ReAnimated anime `translationY` + `opacity`. SwiftUI n'a pas d'animation
« enter » standard sur un `Animated.View` — il faut un `transition` combiné.
Le rendu sera très proche mais pas identique. À valider à l'écran.

### 5.2 Les favoris ne sont pas persistés dans l'app RN

`useState` uniquement → perdu au redémarrage. Deux options :
- reproduire le bug (fidélité stricte) — **déconseillé**, c'est un défaut
- corriger au passage, c'est une amélioration légitime et visible

### 5.3 Les proportions relatives à la hauteur

Sur iPad, `hp(5)` sur 1024 pt de hauteur = 51 pt de titre. L'app sera
dénaturée. SwiftUI donne l'occasion de traiter ça proprement, mais **pas
pendant la migration** — ce sont deux chantiers distincts.

### 5.4 Bug repéré dans l'app d'origine (à ne pas reproduire)

`src/screens/HomeScreen.js:18` :
```js
import { get } from "react-native/Libraries/TurboModule/TurboModuleRegistry";
```
Import d'un module interne de React Native, jamais utilisé. Sans effet, mais
c'est un signal de code peu maintenu. Ne pas porter ce pattern en Swift.

### 5.5 `useEffect` sans tableau de dépendances

`RecipeDetailsScreen.js:32-34` déclenche un appel réseau **à chaque rendu**.
Bug de performance. La version Swift avec `task {}` le résout naturellement.

---

## 6. Checklist de comparaison visuelle

À utiliser pour valider chaque écran contre l'app RN :

**Welcome**
- [ ] Logo centré, proportions 40 % largeur / 40 % hauteur
- [ ] Fond rouge + image de fond en cover
- [ ] Titre blanc, très espacé
- [ ] Bouton blanc, texte rouge, bien centré verticalement

**Home**
- [ ] Avatar et icône filtres alignés en haut
- [ ] « Food You » en noir, « Love » en rouge
- [ ] Barre de recherche : bordure noire fine, coins arrondis
- [ ] Catégorie active en rouge, les autres en gris clair
- [ ] 2 colonnes, première et seconde alignées en haut
- [ ] Hauteurs de cartes alternées (courte / longue)
- [ ] Dégradé noir sur le tiers inférieur de chaque carte
- [ ] Titre de recette blanc, 20 caractères max

**Détails**
- [ ] Image plein largeur, 45 % de la hauteur
- [ ] Boutons retour et cœur bien visibles sur l'image
- [ ] Coins arrondis du contenu blanc qui **chevauchent** l'image
- [ ] Liste d'ingrédients : points rouges alignés à gauche
- [ ] Instructions en paragraphes aérés
- [ ] Contenu apparition en cascade (3 entrées décalées)

---

## 7. Ordre d'exécution recommandé

1. **Phase 0 + 1** — projet vide + design system. Tu valides que la maquette
   de preview ressemble à l'app avant d'aller plus loin. Point de contrôle.
2. **Phase 2** — modèle + réseau. Vérifie avec un vrai appel API.
3. **Phase 3 + 4** — les deux écrans simples. L'app est déjà navigable.
4. **Phase 5** — la grille. Prends le temps, c'est le point dur.
5. **Phase 6** — les détails + animations.
6. **Phase 7** — cache et tests de comparaison.
7. **Phase 8** — shipping.

> **Conseil** : ne cherche pas la perfection avant d'avoir les 3 écrans qui
> fonctionnent. Une première version fonctionnelle que tu compares écran par
> écran vaut mieux qu'un WelcomeScreen parfait qui bloque le projet.

---

## 8. Suivi

| Phase | Statut | Fichiers | Commentaire |
| --- | --- | --- | --- |
| 0 — Socle | Fait | `FoodPad.xcodeproj`, `Assets.xcassets` | bundle `com.armelbogue.foodpad`, iOS 16.0 |
| 1 — Design system | Fait | `Theme/` x4, `DesignSystem/` | 12 couleurs, 14 styles, ecran de reference |
| 2 — Modele + reseau | Fait | `Models/`, `Services/` x3 | 20 champs d'ingredients, 4 endpoints |
| 3 — Welcome | Fait | `WelcomeScreen.swift`, `LottieLogoView.swift` | Lottie branche en SPM |
| 4 — Home | Fait | `HomeScreen.swift`, `Components/` | recherche fonctionnelle (bonus vs RN) |
| 5 — Masonnerie | Fait | `MasonryGrid.swift`, `RecipeCard.swift` | `Layout` SwiftUI maison, 2 colonnes |
| 6 — Details | Fait | `RecipeDetailsScreen.swift` | 3 animations, favori persiste |
| 7 — Cache + finitions | Fait | `CachedImage.swift` | cache disque via `FileManager` |
| 8 — Shipping | Fait | `FoodPadApp.swift` | bundle ID, icone, portrait |

**19 fichiers Swift, 2 708 lignes** (dont 13 nouveaux dans les phases 2 a 8).

### Ecarts assumes avec l'app React Native

Trois differences deliberees, toutes documentees :

1. **Favoris persistes** — l'app RN utilise un `useState`, donc le coeur se
   perd au redemarrage. Corrige via `UserDefaults` (`Services/FavoritesStore.swift`).
2. **Recherche fonctionnelle** — le champ de recherche de l'app RN est
   decoratif. Ici il interroge `search.php`, avec annulation de tache et
   debounce de 400 ms.
3. **`useEffect` sans dependances corrige** — l'app RN relance l'appel reseau
   `lookup.php` a chaque rendu de `RecipeDetailsScreen`. Le `.task` de SwiftUI
   ne s'execute qu'une fois.

### Points a valider a l'oeil

Ces points ne peuvent pas etre verifies par capture d'ecran : ils exigent de
regarder l'app en fonctionnement.

- [ ] **Animation Lottie** — le lecteur est branche et le JSON embarque dans le
      bundle, mais une animation ne se juge pas sur une image fixe
- [ ] **`dampingFraction: 0.7`** — approximation de `.damping(12)` ReAnimated
- [ ] **Transition partagee image** — non implementee : `matchedGeometryEffect`
      combine a `.navigationTransition(.zoom)` exige iOS 18, or la cible est
      iOS 16. A ajouter si tu fais monter la cible.
- [ ] **Icones Heroicons a SF Symbols** — compromis assume, voir section 4
- [ ] **iPad / rotation** — `hp()` etant relatif a la hauteur, le rendu se
      degrade fortement hors portrait. Non traite, cf. section 5.3


---

## 9. Notes d'implémentation

### 9.1 Le projet Xcode est écrit à la main

Aucun outil de génération (`xcodegen`, `tuist`) n'est installé sur cette machine,
et aucune dépendance SPM n'est requise pour les phases 0-1. Le fichier
`ios/FoodPad.xcodeproj/project.pbxproj` est donc **écrit à la main**.

Il utilise `objectVersion = 77` avec un `PBXFileSystemSynchronizedRootGroup`
(le dossier `ios/FoodPad/` est synchronisé automatiquement). Conséquence
pratique : **tu peux créer de nouveaux `.swift` et de nouveaux dossiers sans
toucher au `.pbxproj`** — Xcode les ajoutera tout seul à la target.

⚠️ Nécessite **Xcode 16+**. Une version antérieure refusera de lire le projet.

### 9.2 `hp()` s'appuie sur `UIWindowScene.screen`

L'app React Native lit les dimensions d'écran une fois au montage.
L'implémentation Swift (`Theme/Responsive.swift`) relit
`UIApplication.shared.connectedScenes` **à chaque appel**, ce qui suit le
changement d'orientation sans état à invalider. `UIScreen.main` est évité car
c'est une API dépréciée sur les SDK récents.

### 9.3 Valeurs vérifiées au rendu réel

La capture de `DesignSystemPreview` confirme que les hypothèses de la §2 sont
correctes : les quatre gris `neutral-500/600/700/800` **et** l'accent `#f64e32`
apparaissent effectivement à l'écran. La correspondance avec la palette
Tailwind v3 par défaut est donc validée.

### 9.4 Vérifier un rendu sans l'ouvrir à l'œil

`scripts/inspect-screenshot.py` décode une capture PNG (zlib + struct, sans
aucune dépendance) et rapporte la répartition des couleurs. Pratique pour
contrôler qu'un écran n'est ni vide ni bloqué sur une seule teinte :

```bash
python3 scripts/inspect-screenshot.py docs/phase1-design-system.png
```

### 9.5 Lancer et capturer

```bash
# Build
cd ios
xcodebuild -project FoodPad.xcodeproj -scheme FoodPad \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath /tmp/fp-dd build

# Installer et lancer
xcrun simctl install booted /tmp/fp-dd/Build/Products/Debug-iphonesimulator/FoodPad.app
xcrun simctl launch booted com.armelbogue.foodpad

# Capturer
xcrun simctl io booted screenshot docs/mon-ecran.png
```

Aucune signature de code n'est requise pour le simulateur (signature ad hoc
automatique). Pour un build sur appareil réel, renseigner une `DEVELOPMENT_TEAM`
dans les build settings de la target.

### 9.6 Dépendances SPM

Aucune pour l'instant. À partir de la phase 3 :

| Package | URL | Licence | Pourquoi |
| --- | --- | --- | --- |
| Lottie | `https://github.com/airbnb/lottie-ios` | MIT | Lecture de `food-logo.json` |

Ajout : Xcode → *Project → Add Package Dependencies…*, ou clic droit sur le
`.xcodeproj`. Une fois le paquet ajouté, le `project.pbxproj` contiendra une
section `XCRemoteSwiftPackageReference` — je peux aussi l'écrire directement.

### 9.7 Repli UIKit

La décision « SwiftUI d'abord, UIKit si besoin » reste ouverte. Le seul endroit
où un repli est plausible est la **phase 5** (grille en maçonnerie) :
un `UIViewRepresentable` enveloppant une `UICollectionView` avec un
`UICollectionViewLayout` personnalisé, si le protocole `Layout` de SwiftUI ne
donne pas un rendu satisfaisant. Les phases 0-4 et 6-8 n'en auront pas besoin.

### 9.8 Environnement de référence

| Élément | Valeur |
| --- | --- |
| Xcode | 26.5 (build 17F42) |
| Swift | 6.3.2 |
| SDK | iOS 26.5 |
| Simulateur | iPhone 17 Pro, iOS 26.5 |
| Architecture hôte | x86_64 (Intel) |
| Cible de déploiement | iOS 16.0 |

### 9.9 Piege : l'echelle d'espacement Tailwind n'est PAS en pourcentage

**Erreur commise pendant la migration, corrigee en phase 4.**

L'app React Native melange deux systemes de mesures, et les confondre fausse
silencieusement la mise en page :

| Notation | Origine | Valeur reelle | Exemple |
| --- | --- | --- | --- |
| `hp(n)` / `wp(n)` | `react-native-responsive-screen` | **n % de l'ecran** | `hp(5)` = 5 % |
| `pt-14`, `mx-4`, `space-y-6` | **echelle Tailwind** | **rem fixes** | `pt-14` = 3.5rem = 56 px |

`pt-14` ne vaut pas 14 % de la hauteur. J'ai d'abord ecrit
`padding(.top, 14.hp())` = 122 pt au lieu de 56 pt, ce qui a produit un bandeau
blanc de 66 pt en haut de l'ecran d'accueil — invisible en valeur, mais visible
a l'ecran.

L'echelle Tailwind v3 (racine = 16 px) :

| Classe | rem | px | Classe | rem | px |
| --- | --- | --- | --- | --- | --- |
| `p-1`, `mt-1`, `space-y-1` | 0.25 | 4 | `space-x-4`, `p-4`, `space-y-4` | 1 | 16 |
| `p-2`, `mt-2`, `space-y-2` | 0.5 | 8 | `ml-5`, `mr-5` | 1.25 | 20 |
| `p-3`, `ml-3` | 0.75 | 12 | `space-y-6`, `p-6` | 1.5 | 24 |
| `ml-2`, `left-2` | 0.5 | 8 | `bottom-7` | 1.75 | 28 |
| `px-[6px]` | — | 6 | `pt-14` | 3.5 | 56 |
| `mt-[-46]` | — | -46 | `mt-16` / `mt-20` | 4 / 5 | 64 / 80 |

Rayons : `rounded-xl` = 12, `rounded-full` = cercle.
Bordures : `border` = 1 px.

**Regle** : toute valeur issue d'une classe Tailwind est un multiple de 4 px.
Seuls les `hp()` / `wp()` sont relatifs a l'ecran.

### 9.10 Verifier un rendu sans le voir

`scripts/inspect-screenshot.py` a ete etendu avec un **profil vertical** : il
decoupe la capture en 12 bandes et rapporte, pour chacune, la luminance moyenne
et la part de pixels sombres. C'est ce profil qui a revele le bandeau blanc de
la section 9.9 — la repartition globale des couleurs ne le montrait pas.

```
    8- 16%  luminance 253.9  sombre  0.2%     <- bandeau blanc suspect
   17- 25%  luminance 255.0  sombre  0.0%
   83- 91%  luminance 102.9  sombre 56.8% #### <- cartes + degrades OK
```
