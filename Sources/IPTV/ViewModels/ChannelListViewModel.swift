import Foundation
import Observation

@Observable
@MainActor
final class ChannelListViewModel {
    enum LoadState {
        case loading
        case loaded
        case failed(Error)
    }

    private(set) var channels: [Channel] = []
    private(set) var loadState: LoadState = .loading
    var selectedChannel: Channel?

    var searchText: String = ""
    var countryFilter: String?
    var showOnlyWorkingChannels: Bool = false

    private let service: ChannelService
    var healthStore: StreamHealthStore?

    init(service: ChannelService = IPTVOrgChannelService()) {
        self.service = service
    }

    var availableCountries: [String] {
        Set(channels.compactMap(\.country)).sorted()
    }

    var filteredChannels: [Channel] {
        channels.filter { channel in
            (countryFilter == nil || channel.country == countryFilter)
                && (searchText.isEmpty || channel.name.localizedCaseInsensitiveContains(searchText))
                && (!showOnlyWorkingChannels || (healthStore?.isWorking(channel.id) ?? true))
        }
    }

    /// Category name to group under when a channel has no categories, so it stays browsable.
    private static let uncategorized = "Uncategorized"

    var groupedChannels: [(category: String, channels: [Channel])] {
        var groups: [String: [Channel]] = [:]
        for channel in filteredChannels {
            let categories = channel.categories.isEmpty ? [Self.uncategorized] : channel.categories
            for category in categories {
                groups[category, default: []].append(channel)
            }
        }
        return groups.keys.sorted().map { category in
            (category: category, channels: groups[category] ?? [])
        }
    }

    func load() async {
        loadState = .loading
        do {
            channels = try await service.fetchChannels()
            loadState = .loaded
        } catch {
            loadState = .failed(error)
        }
    }
}
