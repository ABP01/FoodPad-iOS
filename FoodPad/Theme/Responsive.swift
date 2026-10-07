//
//  Responsive.swift
//  FoodPad
//
//  Dimensionnement en pourcentage de l'écran.
//
//      5.hp()  ==  5 % de la hauteur de l'écran
//      40.wp()  ==  40 % de la largeur de l'écran
//
//  ⚠️  Convention relative à la hauteur. Ce n'est pas du responsive design :
//  sur iPad ou en paysage, les valeurs explosent — un titre à 5 % d'une hauteur
//  de 1 024 pt atteint 51 pt. Passer à des contraintes ou à `@ScaledMetric` est
//  un chantier séparé, à ne pas mélanger avec celui-ci.
//

import SwiftUI

enum ScreenMetrics {

    /// Dimensions de l'écran du scene actif.
    /// Relu à chaque appel : suit donc le changement d'orientation.
    static var screenSize: CGSize {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        // `UIWindowScene.screen` est l'API moderne (non dépréciée),
        // contrairement à `UIScreen.main`.
        if let size = scenes.first?.screen.bounds.size, size != .zero {
            return size
        }
        return UIScreen.main.bounds.size
    }

    static var screenHeight: CGFloat { screenSize.height }
    static var screenWidth: CGFloat { screenSize.width }
}

extension CGFloat {

    /// Hauteur en pourcentage de l'écran.
    ///
    ///     5.hp()  ==  5 % de la hauteur de l'écran
    func hp() -> CGFloat {
        self / 100 * ScreenMetrics.screenHeight
    }

    /// Largeur en pourcentage de l'écran.
    ///
    ///     40.wp()  ==  40 % de la largeur de l'écran
    func wp() -> CGFloat {
        self / 100 * ScreenMetrics.screenWidth
    }
}

extension Int {
    /// Variante `Int` de `hp()`, plus lisible pour les valeurs entières
    /// (`hp(45)`, `hp(25)`…).
    func hp() -> CGFloat { CGFloat(self).hp() }
    func wp() -> CGFloat { CGFloat(self).wp() }
}

extension Double {
    func hp() -> CGFloat { CGFloat(self).hp() }
    func wp() -> CGFloat { CGFloat(self).wp() }
}
