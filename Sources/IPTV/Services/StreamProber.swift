import Foundation

/// Cheap liveness check for a stream URL: fetch the HLS playlist (small text file)
/// with a short timeout and treat any 2xx as alive. Not a full playback guarantee,
/// but catches the common failure modes (dead hosts, 403/404, DNS rot).
struct StreamProber: Sendable {
    private let urlSession: URLSession

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 6
        config.timeoutIntervalForResource = 10
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        urlSession = URLSession(configuration: config)
    }

    /// Mimics a real media player/browser rather than a generic HTTP client — several
    /// free IPTV/CDN hosts allow players through but rate-limit or block bare `URLSession`
    /// requests, which was causing the probe to mark live streams as dead.
    private static let playerLikeUserAgent =
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15"

    func isAlive(_ url: URL) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Self.playerLikeUserAgent, forHTTPHeaderField: "User-Agent")

        let maxAttempts = 2
        for attempt in 1 ... maxAttempts {
            if await attemptIsAlive(request) {
                return true
            }
            if attempt < maxAttempts {
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
        return false
    }

    private func attemptIsAlive(_ request: URLRequest) async -> Bool {
        do {
            let (_, response) = try await urlSession.data(for: request)
            guard let http = response as? HTTPURLResponse else { return false }
            return (200 ..< 300).contains(http.statusCode)
        } catch {
            return false
        }
    }
}
