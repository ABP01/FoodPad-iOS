//
//  FoodPadApp.swift
//  FoodPad
//
//  Point d'entrée et pile de navigation.
//
//  Équivalent de `src/navigation/index.js` :
//
//  ```js
//  <Stack.Navigator initialRouteName="Welcome" screenOptions={{ headerShown: false }}>
//    <Stack.Screen name="Home"           component={HomeScreen} />
//    <Stack.Screen name="Welcome"        component={WelcomeScreen} />
//    <Stack.Screen name="RecipeDetails"  component={RecipeDetailsScreen} />
//  </Stack.Navigator>
//  ```
//
//  `Welcome` est la route initiale et les en-têtes sont masqués.
//
//  Les routes sont modélisées par une `enum` plutôt que par des chaînes :
//  SwiftUI transporte alors la recette sélectionnée jusqu'à l'écran de détails
//  sans état mutable partagé.
//

import SwiftUI

// MARK: - Routes

enum Route: Hashable {
    case home
    case recipeDetails(Meal)
}

extension Route {

    /// Pile de navigation initiale, pilotable par un argument de lancement.
    ///
    /// Utile en développement : on peut ouvrir directement l'écran voulu au
    /// lieu de traverser l'accueil à chaque fois.
    ///
    ///     xcrun simctl launch booted com.armelbogue.foodpad -startScreen home
    ///     xcrun simctl launch booted com.armelbogue.foodpad -startScreen details
    ///
    /// Sans argument, la pile est vide et l'app démarre sur l'écran d'accueil
    /// (comportement normal).
    ///
    /// ⚠️  Le raccourci `details` utilise les données de `MockMealService` :
    /// il n'a pas vocation à être utilisé en production.
    static func initialStack(from arguments: [String] = ProcessInfo.processInfo.arguments) -> [Route] {
        guard let index = arguments.firstIndex(of: "-startScreen"),
              arguments.indices.contains(index + 1) else {
            return []
        }

        switch arguments[index + 1] {
        case "home":
            return [.home]
        case "details":
            return [.home, .recipeDetails(MockMealService.detailedMeals[0])]
        default:
            return []
        }
    }
}

// MARK: - Application

@main
struct FoodPadApp: App {

    var body: some Scene {
        WindowGroup {
            RootView()
                .task { Diagnostics.reset() }
        }
    }
}

// MARK: - Navigation racine

struct RootView: View {

    /// Service de données. Injecté pour permettre previews et tests avec
    /// `MockMealService`, hors ligne.
    var service: MealService = LiveMealService()

    @State private var path: [Route] = Route.initialStack()

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeScreen {
                // Le bouton « Get Started » empile l'accueil par-dessus,
                // comme `navigation.navigate("Home")` en React Navigation.
                path.append(Route.home)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .home:
                    HomeScreen(service: service) { meal in
                        path.append(.recipeDetails(meal))
                    }

                case .recipeDetails(let meal):
                    RecipeDetailsScreen(meal: meal, service: service)
                }
            }
        }
        .tint(Theme.accent)
    }
}

// MARK: - Previews

#Preview("Welcome") {
    RootView(service: MockMealService(latency: .zero))
}

#Preview("Home") {
    NavigationStack {
        HomeScreen(service: MockMealService(latency: .zero)) { _ in }
    }
}

#Preview("Fiche recette") {
    NavigationStack {
        RecipeDetailsScreen(meal: MockMealService.detailedMeals[0],
                            service: MockMealService(latency: .zero))
    }
}
