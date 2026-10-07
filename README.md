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

FoodPad est une application iOS de recettes : on parcourt un grand catalogue,
on filtre par catégorie, on cherche un plat au clavier et on consulte la fiche
complète (ingrédients, quantités, instructions).

Le projet est né d'une envie simple : disposer d'un carnet de recettes toujours
à jour, consultable hors ligne et agréable à utiliser sur téléphone.

## ✨ Fonctionnalités

- **Écran d'accueil animé** avec logo Lottie
- **14 catégories** (Bœuf, Poulet, Fruits de mer, Végétarien, Dessert, Vegan…)
  sélectionnables en un tap
- **Grille de recettes** en deux colonnes, avec un affichage en mosaïque
- **Fiche recette** avec grande photo, origine, ingrédients et instructions
- **Recherche instantanée** pendant la frappe
- **Filtres** par catégorie ou « favoris uniquement »
- **Favoris** enregistrés sur le téléphone et consultables hors ligne
- **Liens utiles** vers la vidéo YouTube et la recette d'origine quand il y en a
- **Images mises en cache** : elles s'affichent vite et sans recharger deux fois
- **Accessibilité** : VoiceOver lit chaque bouton, les états sont annoncés


---

## 🚀 Lancer le projet

**Prérequis :** un Mac avec [Xcode](https://developer.apple.com/xcode/).

1. Ouvre `ios/FoodPad.xcodeproj` dans Xcode
2. Choisis un simulateur iPhone (ou ton téléphone)
3. Appuie sur ▶

C'est tout. Aucune dépendance à installer : le projet n'utilise que les
frameworks d'Apple.

> Les recettes viennent de l'API gratuite
> [TheMealDB](https://www.themealdb.com/api.php), sans clé d'accès.

---

## 🛠 Pour les curieux

| | |
| --- | --- |
| **Langage** | Swift 5 |
| **Interface** | SwiftUI (iOS 16 et +) |
| **Réseau & stockage** | `URLSession`, favoris et images gardés en local |
| **Dépendances** | aucune — uniquement les frameworks système |

Les décisions de conception, les points d'attention et l'historique du projet
sont détaillés dans **[MIGRATION_SWIFT.md](./MIGRATION_SWIFT.md)**.

## 🛤 Feuille de route

- [x] Recherche, favoris persistés, cache d'images
- [x] Filtres, liens vers la vidéo et la source
- [ ] Animation Lottie au démarrage
- [ ] Mode hors ligne complet
- [ ] Meilleure prise en charge de l'iPad
- [ ] Publier sur l'App Store

---

## 👤 Auteur

**Armel Bogue** — [GitHub](https://github.com/ABP01)

---

## 📜 Crédits & licence

- MIT License — voir [`LICENSE`](./LICENSE)
- Recettes et images fournies par [TheMealDB](https://www.themealdb.com/api.php)

---

<div align="center">
<sub>Construit avec ❤️ en Swift &amp; SwiftUI</sub>
</div>

