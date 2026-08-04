import Foundation
import Observation

/// Session-scoped programme-guide cache. Guides are fetched lazily per country
/// code, kept in memory only, and considered fresh for an hour — matching the
/// catalog's session-cache philosophy. Countries without a hosted feed are
/// remembered so they aren't re-requested every switch.
@Observable
@MainActor
final class EPGStore {
    private let service = EPGService()
    private var guideByCountry: [String: [String: [EPGProgramme]]] = [:]
    private var fetchedAt: [String: Date] = [:]
    private var countriesWithoutFeed: Set<String> = []
    private var inFlight: Set<String> = []
    /// Bumped when a guide lands so SwiftUI re-reads `currentProgramme` results.
    private(set) var version = 0

    private static let refreshInterval: TimeInterval = 3600

    /// The programme airing now on `channel`, if the session has guide data for it.
    func currentProgramme(for channel: Channel) -> EPGProgramme? {
        guard let countryCode = channel.countryCode,
              let guide = guideByCountry[countryCode]
        else { return nil }

        let feedID = EPGService.feedIDByChannelID[channel.id] ?? channel.id
        guard let programmes = guide[EPGService.normalizeChannelID(feedID)] else { return nil }
        let now = Date()
        return programmes.first { $0.start <= now && now < $0.stop }
    }

    /// Kicks off a guide fetch for the country if it has none or its guide is
    /// stale. Failures degrade silently — browsing/playback never depend on EPG.
    func loadGuideIfNeeded(countryCode: String?) {
        guard let countryCode,
              !countriesWithoutFeed.contains(countryCode),
              !inFlight.contains(countryCode)
        else { return }
        if let fetched = fetchedAt[countryCode], Date().timeIntervalSince(fetched) < Self.refreshInterval {
            return
        }

        inFlight.insert(countryCode)
        Task {
            defer { inFlight.remove(countryCode) }
            do {
                let guide = try await service.fetchGuide(countryCode: countryCode)
                guideByCountry[countryCode] = guide
                fetchedAt[countryCode] = Date()
                version += 1
                NSLog("EPGStore: guide loaded for %@ (%d channels)", countryCode, guide.count)
            } catch EPGService.EPGError.noFeedForCountry {
                countriesWithoutFeed.insert(countryCode)
                NSLog("EPGStore: no hosted feed for %@", countryCode)
            } catch {
                NSLog("EPGStore: guide fetch failed for %@: %@", countryCode, String(describing: error))
            }
        }
    }
}
