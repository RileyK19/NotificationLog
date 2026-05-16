import SwiftUI

struct NotificationDetailView: View {
    let notification: AppNotification
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Hero image (if present)
                    if let imageURLStr = notification.details?.imageURL,
                       let url = URL(string: imageURLStr) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 220)
                                    .clipped()
                            case .empty:
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .frame(height: 220)
                                    .overlay(ProgressView())
                            default:
                                EmptyView()
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        // Header row
                        HStack(spacing: 12) {
                            RemoteImage(notification.icon, size: 44)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(notification.title)
                                    .font(.title3)
                                    .fontWeight(.semibold)

                                Text(notification.dateAdded.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Divider()

                        // Description
                        if let desc = notification.details?.description {
                            Text(desc)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("No additional details.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
