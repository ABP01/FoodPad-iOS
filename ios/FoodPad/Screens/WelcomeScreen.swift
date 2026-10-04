//
//  WelcomeScreen.swift
//  FoodPad
//
//  Écran d'introduction.
//  Traduction de `src/screens/WelcomeScreen.js`.
//  Voir MIGRATION_SWIFT.md § Phase 3.
//

import SwiftUI

struct WelcomeScreen: View {

    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            // Fond rouge de l'app
            Theme.accent
                .ignoresSafeArea()

            // Image de fond, en cover, derrière le lottie
            Image("Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            content
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea(edges: .bottom)
    }

    private var content: some View {
        VStack(spacing: 10.hp()) {
            Spacer(minLength: 0)

            // Animation du logo
            LottieLogoView()
                .accessibilityHidden(true)

            // Titre + sous-titre
            VStack(spacing: 2.hp()) {
                Text("FoodPad")
                    .font(Typo.welcomeTitle)
                    .tracking(Typo.welcomeTracking)
                    .foregroundStyle(.white)

                Text("Explore some delicious Food")
                    .font(Typo.welcomeSubtitle)
                    .tracking(Typo.subtitleTracking)
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 0)

            // Bouton principal
            Button(action: onGetStarted) {
                Text("Get Started")
                    .font(Typo.welcomeButton)
                    .foregroundStyle(Theme.accent)
                    .padding(.vertical, 1.5.hp())
                    .padding(.horizontal, 5.hp())
                    .background(.white, in: RoundedRectangle(cornerRadius: 1.5.hp()))
            }
            .buttonStyle(PressableStyle())
            .padding(.bottom, 5.hp())
            .accessibilityLabel("Get Started")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Effet de bouton

/// Effet d'enfoncement simple. L'app React Native utilise `TouchableOpacity`
/// (l'opacité varie au toucher) — on s'en approche avec un léger scale.
struct PressableStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Navigation

/// Destination « Welcome » du `NavigationStack` racine.
///
/// Dans l'app React Native, `Welcome` est `initialRouteName` de la pile et
/// `Home` est empilé par-dessus : le bouton « Get Started » empile l'accueil.
/// On reproduit ce comportement en naviguant vers `home`.
struct WelcomeDestination {
    static let route = "welcome"
}

#Preview("Welcome") {
    WelcomeScreen(onGetStarted: {})
}
