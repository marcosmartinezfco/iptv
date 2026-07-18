import SwiftUI

struct ContentView: View {
    @State private var healthStore = StreamHealthStore()
    @State private var viewModel = ChannelListViewModel()
    @State private var playerViewModel = PlayerViewModel()

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            if let channel = viewModel.selectedChannel {
                PlayerView(viewModel: playerViewModel)
                    .navigationTitle(channel.name)
            } else {
                Text("Select a channel")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            viewModel.healthStore = healthStore
            playerViewModel.healthStore = healthStore
            await viewModel.load()
        }
        .onChange(of: viewModel.selectedChannel) { _, newChannel in
            playerViewModel.play(channel: newChannel)
        }
    }

    @ViewBuilder
    private var sidebar: some View {
        switch viewModel.loadState {
        case .loading:
            skeletonList
        case .failed:
            ContentUnavailableView {
                Label("Couldn't load channels", systemImage: "wifi.exclamationmark")
            } actions: {
                Button("Retry") {
                    Task { await viewModel.load() }
                }
            }
        case .loaded:
            channelList
        }
    }

    private var skeletonList: some View {
        List {
            ForEach(0..<8, id: \.self) { _ in
                SkeletonChannelRowView()
            }
        }
        .navigationTitle("Channels")
    }

    private var channelList: some View {
        VStack(spacing: 0) {
            filterBar
            if viewModel.filteredChannels.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            } else {
                List(selection: $viewModel.selectedChannel) {
                    ForEach(viewModel.groupedChannels, id: \.category) { group in
                        Section(group.category) {
                            ForEach(group.channels) { channel in
                                ChannelRowView(channel: channel).tag(channel)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search channels")
        .navigationTitle("Channels")
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            Picker("Country", selection: $viewModel.countryFilter) {
                Text("All Countries").tag(String?.none)
                ForEach(viewModel.availableCountries, id: \.self) { country in
                    Text(country).tag(String?.some(country))
                }
            }
            Toggle("Show only working channels", isOn: $viewModel.showOnlyWorkingChannels)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
