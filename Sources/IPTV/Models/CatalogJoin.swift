import Foundation

enum CatalogJoin {
    /// Merges the four iptv-org catalog arrays into `[Channel]`, keyed by channel id.
    /// Channels with no matching stream are kept (browsable, not playable).
    static func join(
        channels: [CatalogDTO.ChannelEntry],
        streams: [CatalogDTO.StreamEntry],
        countries: [CatalogDTO.CountryEntry],
        categories: [CatalogDTO.CategoryEntry]
    ) -> [Channel] {
        let streamURLByChannel = Dictionary(
            streams.compactMap { stream in stream.channel.map { ($0, stream.url) } },
            uniquingKeysWith: { first, _ in first }
        )
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
                logoURL: entry.logo,
                streamURL: streamURLByChannel[entry.id]
            )
        }
    }
}
