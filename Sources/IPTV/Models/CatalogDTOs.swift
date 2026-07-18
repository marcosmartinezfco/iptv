import Foundation

/// Raw shapes decoded directly from `iptv-org/api`'s JSON endpoints, before joining into `Channel`.
enum CatalogDTO {
    struct ChannelEntry: Codable {
        let id: String
        let name: String
        let country: String?
        let categories: [String]?
        let logo: URL?
    }

    struct StreamEntry: Codable {
        let channel: String?
        let url: URL
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
