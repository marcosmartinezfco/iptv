import Foundation

struct Channel: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let country: String?
    /// ISO country code from the source catalog (e.g. "ES") — used to pick
    /// country-scoped auxiliary feeds like the programme guide.
    let countryCode: String?
    let categories: [String]
    let logoURL: URL?
    /// Playable stream URLs in priority order: curated official broadcaster URLs
    /// first, then community-catalog URLs in their source order. Empty means
    /// browsable but not playable.
    let streamSources: [URL]
}
