import SwiftUI
import Shimmer

struct SkeletonChannelRowView: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 28, height: 28)

            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 140, height: 14)

            Spacer(minLength: 0)
        }
        .shimmering()
    }
}
