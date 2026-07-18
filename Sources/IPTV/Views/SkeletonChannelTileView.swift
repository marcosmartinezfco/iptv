import Shimmer
import SwiftUI

struct SkeletonChannelTileView: View {
    var body: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .frame(height: 96)
                .padding(.top, 14)
                .padding(.horizontal, 14)

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .frame(width: 84, height: 9)
                .padding(.bottom, 18)
        }
        .frame(width: 132)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Theme.stroke, lineWidth: 1)
        )
        .shimmering()
    }
}
