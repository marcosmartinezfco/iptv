import Shimmer
import SwiftUI

struct SkeletonChannelTileView: View {
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .frame(width: 100, height: 100)

            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .frame(width: 80, height: 10)
        }
        .frame(width: 120)
        .shimmering()
    }
}
