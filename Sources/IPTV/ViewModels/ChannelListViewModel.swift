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
            channel.streamURL != nil
                && (countryFilter == nil || channel.country == countryFilter)
                && (searchText.isEmpty || channel.name.localizedCaseInsensitiveContains(searchText))
                && (!showOnlyWorkingChannels || (healthStore?.isWorking(channel.id) ?? true))
        }
    }

    var alphabeticalChannels: [Channel] {
        filteredChannels.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
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
