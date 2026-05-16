import SwiftUI

public struct NotificationLogView: View {
    @ObservedObject var viewModel: NotificationLogViewModel
    @State private var selectedNotification: AppNotification?

    public init(viewModel: NotificationLogViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    loadingView
                } else if viewModel.notifications.isEmpty {
                    emptyView
                } else {
                    list
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.isShowingLog = false
                    }
                }
                if viewModel.isLoading {
                    ToolbarItem(placement: .cancellationAction) {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .sheet(item: $selectedNotification) { notif in
            NotificationDetailView(notification: notif)
        }
        .onAppear {
            viewModel.markAllSeen()
        }
    }

    // MARK: - Subviews

    private var list: some View {
        List {
            ForEach(groupedByDate, id: \.key) { section in
                Section(header: Text(section.key)) {
                    ForEach(section.value) { notif in
                        NotificationRowView(notification: notif)
                            .onTapGesture {
                                selectedNotification = notif
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading notifications…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No notifications yet")
                .font(.headline)
            Text("Check back later for updates.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Grouping

    private var groupedByDate: [(key: String, value: [AppNotification])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        var groups: [String: [AppNotification]] = [:]
        for n in viewModel.notifications {
            let day = calendar.startOfDay(for: n.dateAdded)
            let label: String
            if day == today {
                label = "Today"
            } else if day == yesterday {
                label = "Yesterday"
            } else {
                label = n.dateAdded.formatted(date: .abbreviated, time: .omitted)
            }
            groups[label, default: []].append(n)
        }

        // Sort sections: Today first, Yesterday second, rest by date desc
        let order: [String: Int] = ["Today": 0, "Yesterday": 1]
        return groups
            .map { (key: $0.key, value: $0.value) }
            .sorted {
                let a = order[$0.key] ?? 2
                let b = order[$1.key] ?? 2
                if a != b { return a < b }
                return ($0.value.first?.dateAdded ?? .distantPast) > ($1.value.first?.dateAdded ?? .distantPast)
            }
    }
}
