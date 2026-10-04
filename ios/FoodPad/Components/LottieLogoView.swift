//
//  LottieLogoView.swift
//  FoodPad
//
//  Lecteur de l'animation `assets/lottie/food-logo.json`.
//
//  Lottie est ajouté en dépendance Swift Package Manager. Le code est protégé
//  par `#if canImport(Lottie)` : si le paquet n'est pas résolu, l'app compile
//  quand même et affiche le logo en image statique. Cela évite qu'un problème
//  de résolution SPM bloque tout le projet.
//
//  Pour ajouter le paquet :
//  Xcode → File → Add Package Dependencies…
//  ou `https://github.com/airbnb/lottie-ios` (MIT).
//

import SwiftUI

#if canImport(Lottie)
import Lottie
#endif

struct LottieLogoView: View {

    /// Dimensions imposées par l'app d'origine : `wp(40)` × `hp(40)`.
    var width: CGFloat = 40.wp()
    var height: CGFloat = 40.hp()

    /// Nom du fichier JSON dans le bundle.
    var resourceName: String = "food-logo"

    var body: some View {
        Group {
            #if canImport(Lottie)
            if let animation = Self.animation(named: resourceName) {
                LottieAnimationView(animation: animation)
                    .playing(loopMode: .loop)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                fallback
            }
            #else
            fallback
            #endif
        }
        .frame(width: width, height: height)
    }

    /// Repli sans Lottie : la première image de l'animation n'est pas
    /// exploitable directement, on affiche donc le dégradé de fond de l'app.
    private var fallback: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.white.opacity(0.15))
            .overlay(
                Image(systemName: "fork.knife")
                    .font(.system(size: height * 0.3, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))
            )
    }

    #if canImport(Lottie)
    private static func animation(named name: String) -> LottieAnimation? {
        // Cherche d'abord le JSON embarqué en tant que ressource.
        if let url = Bundle.main.url(forResource: name, withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            return LottieAnimation(data: data)
        }
        // Puis le nom du fichier complet (variante "name.json").
        if let url = Bundle.main.url(forResource: name + ".json", withExtension: nil),
           let data = try? Data(contentsOf: url) {
            return LottieAnimation(data: data)
        }
        return nil
    }
    #endif
}
