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
        // Keep every stream URL per channel (source order), not just the first —
        // playback fails over through the list. The curated official-broadcaster
        // URL, when one exists, goes first and duplicates of it are dropped.
        var streamURLsByChannel: [String: [URL]] = [:]
        for stream in streams {
            guard let channelID = stream.channel else { continue }
            streamURLsByChannel[channelID, default: []].append(stream.url)
        }
        for (channelID, official) in OfficialStreams.urlByChannelID {
            var urls = streamURLsByChannel[channelID] ?? []
            urls.removeAll { $0 == official }
            streamURLsByChannel[channelID] = [official] + urls
        }
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
                countryCode: entry.country,
                categories: (entry.categories ?? []).compactMap { categoryNameByID[$0] },
                logoURL: logoURLByChannel[entry.id],
                streamSources: streamURLsByChannel[entry.id] ?? []
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
