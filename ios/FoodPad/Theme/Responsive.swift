//
//  Responsive.swift
//  FoodPad
//
//  Équivalent Swift de `react-native-responsive-screen`.
//
//  L'app React Native d'origine dimensionne sa mise en page en pourcentage de
//  la hauteur / largeur de l'écran :
//
//      heightPercentageToDP(5)  ->  5 % de la hauteur de l'écran
//      widthPercentageToDP(40)   ->  40 % de la largeur de l'écran
//
//  On reproduit cette convention à l'identique pour que le rendu SwiftUI soit
//  pixel-compatible avec l'app d'origine.
//
//  ⚠️  Convention_relative_à_la_hauteur — voir §2 du plan de migration.
//  Ce n'est pas du responsive design : sur iPad ou en paysage, les valeurs
//  explosent. La migration vers des contraintes / @ScaledMetric est un chantier
//  séparé, à ne pas mélanger avec celui-ci.
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
    ///
    /// - Important: Beware of Android conversion, see react-native docs.
    ///   Unités en points iOS, pas en dp Android.
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
    /// issues du code d'origine (`hp(45)`, `hp(25)`…).
    func hp() -> CGFloat { CGFloat(self).hp() }
    func wp() -> CGFloat { CGFloat(self).wp() }
}

extension Double {
    func hp() -> CGFloat { CGFloat(self).hp() }
    func wp() -> CGFloat { CGFloat(self).wp() }
}
