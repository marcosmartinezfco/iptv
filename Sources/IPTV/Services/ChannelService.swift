import Foundation

/// Fetches channel catalog data. Backed by iptv-org's public API/repo today;
/// swap the implementation without touching call sites.
protocol ChannelService: Sendable {
    func fetchChannels() async throws -> [Channel]
}

struct PlaceholderChannelService: ChannelService {
    func fetchChannels() async throws -> [Channel] {
        []
    }
}
