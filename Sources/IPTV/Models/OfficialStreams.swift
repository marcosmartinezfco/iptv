import Foundation

/// Curated official broadcaster stream URLs, keyed by iptv-org channel id.
/// These outrank community-scraped catalog URLs in a channel's source list —
/// first-party endpoints are more reliable and unambiguously legal. Extend via PR;
/// every URL here must be hand-verified to play before landing.
enum OfficialStreams {
    // swiftformat:disable trailingCommas
    static let urlByChannelID: [String: URL] = [
        // RTVE (Spanish public broadcaster) — verified 2026-08-04
        "La1.es": URL(string: "https://rtvelivestream.rtve.es/rtvesec/la1/la1_main.m3u8")!,
        "La2.es": URL(string: "https://rtvelivestream.rtve.es/rtvesec/la2/la2_main.m3u8")!,
        "Teledeporte.es": URL(string: "https://rtvelivestream.rtve.es/rtvesec/tdp/tdp_main.m3u8")!,
        "Clan.es": URL(string: "https://rtvelivestream.rtve.es/rtvesec/clan/clan_main.m3u8")!
    ]
    // swiftformat:enable trailingCommas
}
