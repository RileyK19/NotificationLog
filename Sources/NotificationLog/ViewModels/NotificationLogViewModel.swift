import SwiftUI

@MainActor
public final class NotificationLogViewModel: ObservableObject {

    // MARK: - Published state

    @Published public private(set) var notifications: [AppNotification] = []
    @Published public private(set) var unread: [AppNotification] = []
    @Published public var isShowingLog: Bool = false
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var lastError: Error? = nil

    // MARK: - Private

    private let service: NotificationLogService
    private let config: NotificationLogConfig
    private var pollTask: Task<Void, Never>?

    private var seenIDs: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: seenKey) ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: seenKey) }
    }
    private var seenKey: String { "NotificationLog.seen.\(config.appID)" }

    // MARK: - Init

    public init(config: NotificationLogConfig) {
        self.config = config
        self.service = NotificationLogService(config: config)
    }

    // MARK: - Lifecycle

    public func start() {
        Task { await fetch() }
        startPolling()
    }

    public func stop() {
        pollTask?.cancel()
        pollTask = nil
    }

    // MARK: - Public API

    public func showLog() {
        markAllSeen()
        isShowingLog = true
    }

    public func markAllSeen() {
        var seen = seenIDs
        seen.formUnion(notifications.map(\.id))
        seenIDs = seen
        unread = []
    }

    public func refresh() async {
        await fetch()
    }

    // MARK: - Internal

    private func fetch() async {
        isLoading = true
        lastError = nil
        do {
            let fetched = try await service.fetchNotifications()
            notifications = fetched
            let seen = seenIDs
            unread = fetched.filter { !seen.contains($0.id) }
            if !unread.isEmpty && !isShowingLog {
                isShowingLog = true
                markAllSeen()
            }
        } catch {
            lastError = error
        }
        isLoading = false
    }

    private func startPolling() {
        guard let interval = config.pollInterval, interval > 0 else { return }
        pollTask?.cancel()
        pollTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { break }
                await fetch()
            }
        }
    }
}
