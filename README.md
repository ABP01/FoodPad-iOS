<div align="center">

# 🍳 FoodPad

**Explorez des milliers de recettes, à votre rythme.**

Application mobile de recettes construite avec React Native & Expo.

[![React Native](https://img.shields.io/badge/React%20Native-0.72-20232A?style=flat-square&logo=react)](https://reactnative.dev)
[![Expo](https://img.shields.io/badge/Expo-~49.0-000020?style=flat-square&logo=expo)](https://expo.dev)
[![NativeWind](https://img.shields.io/badge/NativeWind-2.0-38BDF8?style=flat-square&logo=tailwindcss)](https://www.nativewind.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](./LICENSE)

</div>

---

## 📱 À propos

FoodPad est une application mobile qui permet de parcourir un large catalogue de
recettes, de les filtrer par catégorie et de consulter le détail de chaque plat
(ingrédients, quantités, instructions).

Le projet est né d'une envie simple : disposer d'un carnet de recettes toujours
à jour, consultable hors ligne et pleasant à utiliser sur téléphone.

### ✨ Fonctionnalités

- **Écran d'accueil animé** — logo Lottie et transition vers l'app en un clic
- **Navigation fluide** — pile de screens native stack, headers masqués, transitions partagées
- **Catégories** — 14 catégories (Bœuf, Poulet, Fruits de mer, Végétarien, Dessert, Vegan…) sélectionnables en un tap
- **Grille en maçonnerie** — 2 colonnes avec hauteurs variables, chargement progressif au scroll
- **Fiche recette détaillée** — image HD, origine du plat, ingrédients avec mesures, instructions
- **Cache d'images** — les images de plats sont converties en base 64 et stockées en `AsyncStorage` pour un affichage instantané
- **Animations Reanimated** — entrées en `FadeInDown` avec spring, image partagée entre les écrans
- **Responsive** — toutes les tailles reposent sur `react-native-responsive-screen`
- **UI NativeWind** — styles utilitaires TailwindCSS, zéro `StyleSheet` manuel

### 🛠 Stack technique

| Couche | Technologie |
| --- | --- |
| Framework | React Native 0.72 + Expo SDK 49 |
| Langage | JavaScript |
| Styles | NativeWind 2 / TailwindCSS 3 |
| Animations | React Native Reanimated 3, Lottie |
| Navigation | React Navigation 6 (native-stack) |
| Réseau | Axios |
| Icônes | Heroicons |
| Grille | @react-native-seoul/masonry-list |
| Stockage | AsyncStorage |
| API | [TheMealDB](https://www.themealdb.com/api.php) — API gratuite de recettes |

### 🔌 API utilisée

Toutes les données proviennent de l'API publique gratuite
[TheMealDB](https://www.themealdb.com/api.php). Aucune clé n'est requise.

| Endpoint | Utilisation |
| --- | --- |
| `GET /categories.php` | Liste des catégories |
| `GET /filter.php?c={catégorie}` | Recettes filtrées par catégorie |
| `GET /lookup.php?i={id}` | Détail complet d'une recette |

---

## 🚀 Installation & lancement

**Prérequis :** [Node.js](https://nodejs.org) 18+, [Expo Go](https://expo.io/go)
installé sur votre téléphone, ou un simulateur iOS / Android.

```bash
# 1. Installer les dépendances
npm install

# 2. Lancer le serveur de développement
npm start
```

Un QR code s'affiche dans le terminal : scannez-le avec **Expo Go** pour ouvrir
l'app sur votre téléphone. Le rechargement est automatique à chaque modification
de fichier.

### Scripts disponibles

| Commande | Action |
| --- | --- |
| `npm start` | Démarre le serveur Expo (QR code + menu) |
| `npm run ios` | Lance et ouvre l'app dans le simulateur iOS (macOS) |
| `npm run android` | Lance et ouvre l'app sur un appareil / émulateur Android |
| `npm run web` | Lance la version web (nécessite `npx expo install react-dom react-native-web`) |

---

## 📁 Structure du projet

```
.
├── App.js                     # Point d'entrée : rendu de la navigation
├── app.json                   # Config Expo (nom, icônes, splash, slug)
├── assets/
│   ├── images/                # Avatar, fond de l'écran welcome
│   ├── lottie/                # Animation du logo
│   ├── icon.png               # Icône de l'app
│   ├── splash.png             # Écran de démarrage
│   └── adaptive-icon.png      # Icône Android
├── src/
│   ├── components/
│   │   ├── Categories.js      # Sélecteur horizontal de catégories
│   │   ├── Loading.js         # Indicateur de chargement
│   │   ├── Recipes.js         # En-tête + grille en maçonnerie
│   │   └── RecipesCard.js     # Carte d'une recette
│   ├── constants/
│   │   └── index.js           # Données statiques (descriptions de catégories)
│   ├── navigation/
│   │   └── index.js           # Stack de navigation (Welcome → Home → RecipeDetails)
│   └── screens/
│       ├── WelcomeScreen.js   # Écran d'introduction animé
│       ├── HomeScreen.js      # Catégories + grille de recettes + recherche
│       └── RecipeDetailsScreen.js  # Fiche détaillée d'une recette
├── utils/
│   └── index.js               # CachedImage : cache base 64 via AsyncStorage
├── babel.config.js            # Config Babel (plugin NativeWind)
└── tailwind.config.js         # Config TailwindCSS
```

---

## 🎬 Captures d'écran

> À compléter — déposez vos captures dans `docs/` et référencez-les ici :
>
> | Welcome | Accueil | Fiche recette |
> | --- | --- | --- |
> | `![Welcome](docs/welcome.png)` | `![Accueil](docs/home.png)` | `![Fiche](docs/details.png)` |

---

## 🛤 Feuille de route

- [ ] Brancher réellement la barre de recherche (filtrage côté API via `search.php`)
- [ ] Persister les favoris avec `AsyncStorage`
- [ ] Mode hors ligne complet avec cache des réponses JSON
- [ ] Ajouter un système de notes / commentaires
- [ ] Re-lier le projet à ton compte Expo (`npx eas init`) puis publier sur l'App Store et le Play Store via EAS Build
- [ ] Remplacer les images de marque restantes (`assets/icon.png`, `assets/splash.png`, `assets/lottie/food-logo.json`) par des visuels FoodPad

---

## 👤 Auteur

**Armel Bogue** — [GitHub](https://github.com)

---

## 📜 Crédits & licence

Ce projet est une adaptation d'un food app open source React Native
initialement publié sur GitHub par **Joe Stacks** — un grand merci à lui pour
le design et la base de code.

- MIT License — voir [`LICENSE`](./LICENSE)
- Recettes et images fournies par [TheMealDB](https://www.themealdb.com/api.php)
- Icônes : [Heroicons](https://heroicons.com) (MIT)

---

<div align="center">
<sub>Construit avec ❤️ en React Native &amp; Expo</sub>
</div>
