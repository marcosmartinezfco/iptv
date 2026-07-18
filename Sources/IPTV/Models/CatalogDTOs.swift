import Foundation

/// Raw shapes decoded directly from `iptv-org/api`'s JSON endpoints, before joining into `Channel`.
enum CatalogDTO {
    struct ChannelEntry: Codable {
        let id: String
        let name: String
        let country: String?
        let categories: [String]?
    }

    struct StreamEntry: Codable {
        let channel: String?
        let url: URL
    }

    /// Logos live in their own `logos.json` endpoint, keyed by channel id
    /// (the old inline `channel.logo` field was removed from the API).
    struct LogoEntry: Codable {
        let channel: String
        let url: URL
        let format: String?
        let inUse: Bool?

        enum CodingKeys: String, CodingKey {
            case channel, url, format
            case inUse = "in_use"
        }
    }

    struct CountryEntry: Codable {
        let code: String
        let name: String
    }

    struct CategoryEntry: Codable {
        let id: String
        let name: String
    }
}
