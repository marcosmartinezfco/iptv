import Foundation

/// Fetches channel catalog data. Backed by iptv-org's public API/repo today;
/// swap the implementation without touching call sites.
protocol ChannelService: Sendable {
    func fetchChannels() async throws -> [Channel]
}

enum ChannelServiceError: Error {
    case network(Error)
    case invalidResponse
    case decoding(Error)
}

struct PlaceholderChannelService: ChannelService {
    func fetchChannels() async throws -> [Channel] {
        []
    }
}

actor IPTVOrgChannelService: ChannelService {
    private static let baseURL = URL(string: "https://iptv-org.github.io/api/")!

    private let urlSession: URLSession
    private var cachedChannels: [Channel]?

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetchChannels() async throws -> [Channel] {
        if let cachedChannels {
            return cachedChannels
        }

        async let channels: [CatalogDTO.ChannelEntry] = fetchJSON("channels.json")
        async let streams: [CatalogDTO.StreamEntry] = fetchJSON("streams.json")
        async let logos: [CatalogLogoEntry] = fetchJSON("logos.json")
        async let countries: [CatalogDTO.CountryEntry] = fetchJSON("countries.json")
        async let categories: [CatalogDTO.CategoryEntry] = fetchJSON("categories.json")

        let joined = try await CatalogJoin.join(
            channels: channels,
            streams: streams,
            logos: logos,
            countries: countries,
            categories: categories
        )

        cachedChannels = joined
        return joined
    }

    /// Fetches and decodes a JSON array, skipping individual entries that fail to decode
    /// rather than failing the whole request.
    private func fetchJSON<T: Decodable>(_ path: String) async throws -> [T] {
        let url = Self.baseURL.appendingPathComponent(path)
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await urlSession.data(from: url)
        } catch {
            throw ChannelServiceError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse, (200 ..< 300).contains(httpResponse.statusCode) else {
            throw ChannelServiceError.invalidResponse
        }

        guard let rawEntries = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw ChannelServiceError.decoding(
                DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Expected a JSON array of objects"))
            )
        }

        let decoder = JSONDecoder()
        return rawEntries.compactMap { entry in
            guard let entryData = try? JSONSerialization.data(withJSONObject: entry) else { return nil }
            return try? decoder.decode(T.self, from: entryData)
        }
    }
}
