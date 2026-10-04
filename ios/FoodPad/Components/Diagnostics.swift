//
//  Diagnostics.swift
//  FoodPad
//
//  Écrit un rapport d'état dans le conteneur de l'app, lisible depuis l'hôte :
//
//      xcrun simctl get_app_container booted com.armelbogue.foodpad data
//      cat <conteneur>/Documents/foodpad-diagnostics.txt
//
//  Utile parce que le rendu ne peut pas être observé directement et que
//  `log stream` est peu fiable sur certaines machines. Utile surtout pour
//  trancher une question concrète : « la grille est-elle vide parce que les
//  données n'arrivent pas, ou parce que la mise en page ne calcule pas de
//  hauteur ? »
//

import Foundation

enum Diagnostics {

    static let fileName = "foodpad-diagnostics.txt"

    static var fileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }

    /// Écrit le rapport en **ajoutant** une ligne horodatée, pour conserver
    /// l'historique des rechargements successifs.
    static func write(_ message: String) {
        guard let url = fileURL else { return }

        let stamp = ISO8601DateFormatter().string(from: Date())
        let line = "[\(stamp)] \(message)\n"

        if let existing = try? String(contentsOf: url, encoding: .utf8) {
            try? (existing + line).write(to: url, atomically: true, encoding: .utf8)
        } else {
            try? line.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    /// Vide le rapport (au lancement de l'app, pour ne pas mélanger les
    /// sessions de test).
    static func reset() {
        guard let url = fileURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
