import Foundation

struct Channel: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let country: String?
    let logoURL: URL?
    let streamURL: URL?
}
