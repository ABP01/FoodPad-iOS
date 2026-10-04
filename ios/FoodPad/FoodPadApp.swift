//
//  FoodPadApp.swift
//  FoodPad
//
//  Point d'entrée de l'app iOS native (migration SwiftUI).
//
//  ⚠️  État d'avancement : phase 1 (design system).
//  Pour l'instant la racine affiche l'écran de référence du design system.
//  Elle sera remplacée par le `NavigationStack` de la phase 3.
//

import SwiftUI

@main
struct FoodPadApp: App {

    var body: some Scene {
        WindowGroup {
            DesignSystemPreview()
        }
    }
}
