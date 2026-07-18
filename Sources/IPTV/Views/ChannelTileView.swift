import NukeUI
import Pow
import SwiftUI

struct ChannelTileView: View {
    let channel: Channel
    let isSelected: Bool

    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 0) {
            logoView
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .padding(.top, 14)
                .padding(.horizontal, 14)

            Text(channel.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isSelected || isHovering ? .primary : .secondary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .padding(.bottom, 12)
        }
        .frame(width: 132)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isHovering ? Theme.surfaceRaised : Theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    isSelected ? Theme.accent : (isHovering ? Color.white.opacity(0.14) : Theme.stroke),
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
        .shadow(
            color: isSelected ? Theme.accent.opacity(0.25) : .black.opacity(isHovering ? 0.4 : 0),
            radius: isSelected ? 10 : 8,
            y: isHovering ? 4 : 2
        )
        .scaleEffect(isHovering ? 1.03 : 1.0)
        .changeEffect(.glow(color: Theme.accent.opacity(0.6), radius: 24), value: isSelected, isEnabled: isSelected)
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onHover { hovering in
            withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                isHovering = hovering
            }
        }
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }

    @ViewBuilder
    private var logoView: some View {
        if let logoURL = channel.logoURL {
            LazyImage(url: logoURL) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    fallbackIcon
                }
            }
        } else {
            fallbackIcon
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: "tv")
            .font(.system(size: 34, weight: .light))
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
