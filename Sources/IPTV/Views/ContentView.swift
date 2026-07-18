import SwiftUI

struct ContentView: View {
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
            ProgressView("Loading channels…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private var channelList: some View {
        VStack(spacing: 0) {
            filterBar
            if viewModel.filteredChannels.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            } else {
                List(viewModel.filteredChannels, selection: $viewModel.selectedChannel) { channel in
                    Text(channel.name).tag(channel)
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search channels")
        .navigationTitle("Channels")
    }

    private var filterBar: some View {
        HStack {
            Picker("Country", selection: $viewModel.countryFilter) {
                Text("All Countries").tag(String?.none)
                ForEach(viewModel.availableCountries, id: \.self) { country in
                    Text(country).tag(String?.some(country))
                }
            }
            Picker("Category", selection: $viewModel.categoryFilter) {
                Text("All Categories").tag(String?.none)
                ForEach(viewModel.availableCategories, id: \.self) { category in
                    Text(category).tag(String?.some(category))
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
