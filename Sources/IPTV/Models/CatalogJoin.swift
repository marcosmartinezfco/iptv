import Foundation

enum CatalogJoin {
    /// Merges the iptv-org catalog arrays into `[Channel]`, keyed by channel id.
    /// Channels with no matching stream are kept (browsable, not playable).
    static func join(
        channels: [CatalogDTO.ChannelEntry],
        streams: [CatalogDTO.StreamEntry],
        logos: [CatalogLogoEntry],
        countries: [CatalogDTO.CountryEntry],
        categories: [CatalogDTO.CategoryEntry]
    ) -> [Channel] {
        let streamURLByChannel = Dictionary(
            streams.compactMap { stream in stream.channel.map { ($0, stream.url) } },
            uniquingKeysWith: { first, _ in first }
        )
        let logoURLByChannel = bestLogoByChannel(logos)
        let countryNameByCode = Dictionary(
            countries.map { ($0.code, $0.name) },
            uniquingKeysWith: { first, _ in first }
        )
        let categoryNameByID = Dictionary(
            categories.map { ($0.id, $0.name) },
            uniquingKeysWith: { first, _ in first }
        )

        return channels.map { entry in
            Channel(
                id: entry.id,
                name: entry.name,
                country: entry.country.flatMap { countryNameByCode[$0] },
                categories: (entry.categories ?? []).compactMap { categoryNameByID[$0] },
                logoURL: logoURLByChannel[entry.id],
                streamURL: streamURLByChannel[entry.id]
            )
        }
    }

    /// A channel can have several logos; prefer raster formats Nuke can decode
    /// (SVG is not supported by its default decoders), and logos marked in use.
    private static func bestLogoByChannel(_ logos: [CatalogLogoEntry]) -> [String: URL] {
        var best: [String: (score: Int, url: URL)] = [:]
        for logo in logos {
            var score = 0
            if logo.inUse ?? false {
                score += 2
            }
            if logo.format?.uppercased() != "SVG" {
                score += 4
            }
            if let current = best[logo.channel], current.score >= score {
                continue
            }
            best[logo.channel] = (score, logo.url)
        }
        return best.mapValues(\.url)
    }
}
