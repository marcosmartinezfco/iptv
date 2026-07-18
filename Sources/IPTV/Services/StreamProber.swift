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

    func isAlive(_ url: URL) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        do {
            let (_, response) = try await urlSession.data(for: request)
            guard let http = response as? HTTPURLResponse else { return false }
            return (200 ..< 300).contains(http.statusCode)
        } catch {
            return false
        }
    }
}
