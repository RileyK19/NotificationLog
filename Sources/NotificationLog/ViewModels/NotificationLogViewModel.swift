import SwiftUI
import FoundationModels

@MainActor
public final class NotificationLogViewModel: ObservableObject {

    // MARK: - Published state

    @Published public private(set) var notifications: [AppNotification] = []
    @Published public private(set) var unread: [AppNotification] = []
    @Published public var isShowingLog: Bool = false
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var lastError: Error? = nil
    @Published public var summaryText: String? = nil

    // MARK: - Private

    private let service: NotificationLogService
    let config: NotificationLogConfig
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
            await getSummary()
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
    
    private func getSummary() async {
        guard #available(iOS 26.0, *) else { return }
        guard SystemLanguageModel.default.availability == .available else { return }
        
        let session = LanguageModelSession()
        let toSummarize = unread.map { "\($0.title): \($0.details?.description ?? "")" }.joined(separator: ". ")
        do {
            let response = try await session.respond(
                to: "summarise these notifications in one sentence \(toSummarize)",
                generating: NotificationSummary.self
            )
            summaryText = response.content.oneSentence
        } catch {
            return
        }
    }
}

@available(iOS 26.0, *)
@Generable
struct NotificationSummary {
    let oneSentence: String
}

#if DEBUG
extension NotificationLogViewModel {
    static func preview(notifications: [AppNotification]) -> NotificationLogViewModel {
        let vm = NotificationLogViewModel(config: NotificationLogConfig(
            supabaseURL: "https://example.supabase.co",
            supabaseAnonKey: "key",
            appID: "com.example.preview"
        ))
        vm.notifications = notifications
        vm.summaryText = "You have 2 updates: an AI summarization feature and upcoming maintenance this Saturday."
        return vm
    }
}
#endif
#Preview {
    NotificationLogView(viewModel: .preview(notifications: [
        AppNotification(
            id: "1",
            appID: "com.example.preview",
            title: "New feature dropped 🎉",
            dateAdded: .now,
            details: NotificationDetails(description: "We just added AI summarization.")
        ),
        AppNotification(
            id: "2",
            appID: "com.example.preview",
            title: "Scheduled maintenance",
            dateAdded: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
            details: NotificationDetails(description: "Saturday 2–4 AM PST.")
        )
    ]))
}
