//
//  CachedImage.swift
//  FoodPad
//
//  Téléchargement d'images avec cache disque.
//
//  ⚠️  Les fichiers vont sur le disque via `FileManager` (dossier Documents),
//  pas dans `UserDefaults` : ce dernier est un stockage clé/valeur intended pour
//  de petits réglages, il sature vite avec des images et ralentit au lancement.
//
//  Le comportement visible : à la seconde visite, l'image s'affiche
//  instantanément depuis le disque.
//

import SwiftUI

// MARK: - Store

/// Cache d'images sur disque, indexé par URL.
actor ImageCache {

    static let shared = ImageCache()

    private let memory = NSCache<NSString, NSData>()
    private let directory: URL

    init() {
        let base = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())

        directory = base.appendingPathComponent("FoodPadImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true
        )
    }

    /// Nom de fichier dérivé de l'URL. Un hachage évite les noms de fichiers
    /// invalides (les URLs contiennent `/`, `?`, `:`…).
    private func fileName(for url: String) -> String {
        let hash = url.hashValue
        return "\(abs(hash))-\(url.utf8.count).img"
    }

    func data(for url: String) -> Data? {
        let key = url as NSString

        if let cached = memory.object(forKey: key) {
            return cached as Data
        }

        let fileURL = directory.appendingPathComponent(fileName(for: url))
        guard let data = try? Data(contentsOf: fileURL) else { return nil }

        memory.setObject(data as NSData, forKey: key)
        return data
    }

    func store(_ data: Data, for url: String) {
        memory.setObject(data as NSData, forKey: url as NSString)
        let fileURL = directory.appendingPathComponent(fileName(for: url))
        try? data.write(to: fileURL, options: .atomic)
    }

    /// Vide le cache disque et mémoire.
    func clear() {
        memory.removeAllObjects()
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true
        )
    }
}

// MARK: - Vue

struct CachedImage<Content: View, Placeholder: View>: View {

    let url: String?
    var contentMode: ContentMode = .fill
    @ViewBuilder var content: (Image) -> Content
    @ViewBuilder var placeholder: () -> Placeholder

    @State private var uiImage: UIImage?
    @State private var isLoading = false

    init(
        url: String?,
        contentMode: ContentMode = .fill,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage).resizable())
            } else {
                placeholder()
            }
        }
        .aspectRatio(contentMode: contentMode)
        .task(id: url) { await load() }
    }

    private func load() async {
        guard let url, !url.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        // 1. Mémoire → 2. Disque → 3. Réseau
        if let cached = await ImageCache.shared.data(for: url),
           let image = UIImage(data: cached) {
            uiImage = image
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: URL(string: url)!)
            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {
                return
            }
            guard let image = UIImage(data: data) else { return }
            uiImage = image
            await ImageCache.shared.store(data, for: url)
        } catch {
            // On laisse le placeholder visible : l'app d'origine fait de même
            // (elle retombe sur l'URL distante, qui échouera aussi).
        }
    }
}

// MARK: - Variantes

extension CachedImage where Content == AnyView, Placeholder == Color {

    /// Version simple, avec un aplat de couleur en attendant l'image.
    init(url: String?, contentMode: ContentMode = .fill) {
        self.init(
            url: url,
            contentMode: contentMode,
            content: { image in AnyView(image) },
            placeholder: { Theme.cardPlaceholder }
        )
    }
}

#Preview("CachedImage") {
    VStack(spacing: 12) {
        CachedImage(
            url: "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg"
        ) { image in
            image
        } placeholder: {
            Theme.cardPlaceholder
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

        Text("Image distante avec cache disque")
            .font(.footnote)
    }
    .padding()
}
