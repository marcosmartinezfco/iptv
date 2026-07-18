import SwiftUI

struct ContentView: View {
    @State private var viewModel = ChannelListViewModel()

    var body: some View {
        NavigationSplitView {
            List(viewModel.channels, selection: $viewModel.selectedChannel) { channel in
                Text(channel.name).tag(channel)
            }
            .navigationTitle("Channels")
        } detail: {
            if let channel = viewModel.selectedChannel {
                Text(channel.name)
                    .font(.title)
            } else {
                Text("Select a channel")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
