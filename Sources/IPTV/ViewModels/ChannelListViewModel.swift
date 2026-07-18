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
    var categoryFilter: String?

    private let service: ChannelService

    init(service: ChannelService = IPTVOrgChannelService()) {
        self.service = service
    }

    var availableCountries: [String] {
        Set(channels.compactMap(\.country)).sorted()
    }

    var availableCategories: [String] {
        Set(channels.flatMap(\.categories)).sorted()
    }

    var filteredChannels: [Channel] {
        channels.filter { channel in
            (countryFilter == nil || channel.country == countryFilter)
                && (categoryFilter == nil || channel.categories.contains(categoryFilter!))
                && (searchText.isEmpty || channel.name.localizedCaseInsensitiveContains(searchText))
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
