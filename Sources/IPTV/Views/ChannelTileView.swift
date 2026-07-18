import NukeUI
import Pow
import SwiftUI

struct ChannelTileView: View {
    let channel: Channel
    let isSelected: Bool

    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 8) {
            logoView
                .frame(width: 100, height: 100)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            isSelected ? Color.accentColor : Color.white.opacity(0.08),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(color: .black.opacity(isHovering ? 0.5 : 0.2), radius: isHovering ? 12 : 4, y: isHovering ? 6 : 2)
                .scaleEffect(isHovering ? 1.06 : 1.0)
                .changeEffect(.jump(height: 8), value: isSelected)

            Text(channel.name)
                .font(.caption)
                .foregroundStyle(isSelected ? .primary : .secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 120)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovering = hovering
            }
        }
    }

    @ViewBuilder
    private var logoView: some View {
        if let logoURL = channel.logoURL {
            LazyImage(url: logoURL) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(12)
                } else {
                    fallbackIcon
                }
            }
        } else {
            fallbackIcon
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: "tv.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(20)
            .foregroundStyle(.secondary)
    }
}
