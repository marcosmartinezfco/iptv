import Foundation

/// One programme airing on a channel.
struct EPGProgramme: Sendable {
    let title: String
    let start: Date
    let stop: Date
}

/// Fetches and parses a hosted per-country XMLTV guide (epgshare01.online's
/// `epg_ripper_<CC>1.xml.gz` dumps — daily-updated, gzip-compressed XMLTV),
/// returning upcoming programmes keyed by a normalized channel identity that
/// `EPGStore` matches against iptv-org channel ids.
///
/// The feed's channel ids differ from iptv-org's in punctuation only
/// (`La.1.es` vs `La1.es`), so both sides are normalized to bare lowercase
/// alphanumerics (country suffix dropped) for matching; the handful of channels
/// whose feed name differs beyond punctuation get explicit aliases.
struct EPGService: Sendable {
    private let urlSession: URLSession

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120
        urlSession = URLSession(configuration: config)
    }

    // swiftformat:disable trailingCommas
    /// iptv-org channel id → the feed's channel id, for names normalization
    /// can't bridge. Keep sorted; verified against the ES1 feed 2026-08-04.
    static let feedIDByChannelID: [String: String] = [
        "24Horas.es": "Canal.24.horas.es",
        "Clan.es": "Clan.TVE.es"
    ]
    // swiftformat:enable trailingCommas

    /// Lowercased alphanumerics with the trailing country suffix removed:
    /// "La.1.es" → "la1", "laSexta.es" → "lasexta". Collisions are theoretically
    /// possible but haven't been observed within a single country feed.
    static func normalizeChannelID(_ id: String) -> String {
        var base = Substring(id)
        if let lastDot = base.lastIndex(of: "."), base[base.index(after: lastDot)...].count == 2 {
            base = base[..<lastDot]
        }
        return base.lowercased().filter { $0.isLetter || $0.isNumber }
    }

    /// Fetches the guide for a country code (e.g. "ES"). Returns programmes still
    /// relevant now or later (ended ones dropped), keyed by normalized feed
    /// channel id. Throws on network/decompression errors; a missing feed for the
    /// country (404) throws `EPGError.noFeedForCountry`.
    func fetchGuide(countryCode: String) async throws -> [String: [EPGProgramme]] {
        let feedPath = "https://epgshare01.online/epgshare01/epg_ripper_\(countryCode.uppercased())1.xml.gz"
        guard let url = URL(string: feedPath) else {
            throw EPGError.noFeedForCountry
        }
        let (data, response) = try await urlSession.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode == 404 {
            throw EPGError.noFeedForCountry
        }
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            throw EPGError.badResponse
        }

        let xml = try Gzip.decompress(data)
        let parser = XMLTVParser()
        return parser.parse(xml)
    }

    enum EPGError: Error {
        case noFeedForCountry
        case badResponse
    }
}

/// Streaming XMLTV parse: extracts `<programme start stop channel><title>` only,
/// dropping programmes that already ended so session memory holds roughly a day
/// of guide, not the feed's full horizon.
private final class XMLTVParser: NSObject, XMLParserDelegate {
    private var programmesByChannel: [String: [EPGProgramme]] = [:]
    private var currentChannel: String?
    private var currentStart: Date?
    private var currentStop: Date?
    private var currentTitle = ""
    private var isInsideTitle = false
    private let now = Date()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    func parse(_ data: Data) -> [String: [EPGProgramme]] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        for (channel, programmes) in programmesByChannel {
            programmesByChannel[channel] = programmes.sorted { $0.start < $1.start }
        }
        return programmesByChannel
    }

    func parser(
        _: XMLParser,
        didStartElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?,
        attributes: [String: String] = [:]
    ) {
        switch elementName {
        case "programme":
            currentChannel = attributes["channel"].map(EPGService.normalizeChannelID)
            currentStart = attributes["start"].flatMap(Self.dateFormatter.date(from:))
            currentStop = attributes["stop"].flatMap(Self.dateFormatter.date(from:))
            currentTitle = ""
        case "title":
            isInsideTitle = currentChannel != nil
        default:
            break
        }
    }

    func parser(_: XMLParser, foundCharacters string: String) {
        if isInsideTitle {
            currentTitle += string
        }
    }

    func parser(
        _: XMLParser,
        didEndElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?
    ) {
        switch elementName {
        case "title":
            isInsideTitle = false
        case "programme":
            defer { currentChannel = nil }
            guard let channel = currentChannel,
                  let start = currentStart,
                  let stop = currentStop,
                  stop > now,
                  !currentTitle.isEmpty
            else { return }
            programmesByChannel[channel, default: []]
                .append(EPGProgramme(title: currentTitle, start: start, stop: stop))
        default:
            break
        }
    }
}
