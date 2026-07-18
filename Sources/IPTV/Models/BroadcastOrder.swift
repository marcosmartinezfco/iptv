import Foundation

/// Curated "TV dial" channel ordering per country, matching how national broadcast
/// (TDT/DVB) guides list channels. iptv-org carries no logical-channel-number data,
/// so this is hand-maintained for the countries we care about; channels not listed
/// here sort alphabetically after the curated block, and countries with no entry
/// are fully alphabetical.
enum BroadcastOrder {
    /// Country name (as joined onto `Channel.country`) → channel ids in dial order.
    private static let orderByCountry: [String: [String]] = [
        "Spain": [
            "La1.es",
            "La2.es",
            "Antena3.es",
            "Cuatro.es",
            "Telecinco.es",
            "LaSexta.es",
            "Neox.es",
            "Nova.es",
            "Energy.es",
            "Mega.es",
            "Atreseries.es",
            "BeMad.es",
            "Divinity.es",
            "Boing.es",
            "Clan.es",
            "Teledeporte.es",
            "24Horas.es",
            "DMAX.es",
            "DKISS.es",
            "Trece.es",
            "TEN.es",
            "ParamountNetwork.es",
            "Gol.es",
            "RealMadridTV.es",
        ],
    ]

    /// Rank of a channel within its country's dial, or nil when not curated.
    static func rank(channelID: String, country: String?) -> Int? {
        guard let country, let order = orderByCountry[country] else { return nil }
        return order.firstIndex(of: channelID)
    }
}
