import SwiftUI

/// Lightweight async image that shows a placeholder while loading.
/// Wraps AsyncImage with a consistent look across the library.
struct RemoteImage: View {
    let urlString: String?
    let size: CGFloat

    init(_ urlString: String?, size: CGFloat = 40) {
        self.urlString = urlString
        self.size = size
    }

    var body: some View {
        Group {
            if let str = urlString, let url = URL(string: str) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: size * 0.22)
            .fill(Color(.systemGray5))
            .overlay(
                Image(systemName: "bell.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(Color(.systemGray3))
            )
    }
}
