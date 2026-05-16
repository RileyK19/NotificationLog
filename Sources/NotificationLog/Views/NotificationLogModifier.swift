import SwiftUI

// MARK: - ViewModifier

/// Attach this modifier to your root view to enable the notification log sheet.
/// The sheet auto-appears when new notifications arrive.
public struct NotificationLogModifier: ViewModifier {
    @StateObject private var viewModel: NotificationLogViewModel

    public init(config: NotificationLogConfig) {
        _viewModel = StateObject(wrappedValue: NotificationLogViewModel(config: config))
    }

    public func body(content: Content) -> some View {
        content
            .environment(\.notificationLogViewModel, viewModel)
            .sheet(isPresented: $viewModel.isShowingLog) {
                NotificationLogView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .task {
                viewModel.start()
            }
            .onDisappear {
                viewModel.stop()
            }
    }
}

// MARK: - View extension

public extension View {
    /// Attaches the notification log to your view hierarchy.
    ///
    /// Usage:
    /// ```swift
    /// ContentView()
    ///     .notificationLog(config: NotificationLogConfig(
    ///         supabaseURL: "https://xxx.supabase.co",
    ///         supabaseAnonKey: "...",
    ///         appID: "com.example.myapp"
    ///     ))
    /// ```
    func notificationLog(config: NotificationLogConfig) -> some View {
        modifier(NotificationLogModifier(config: config))
    }
}

// MARK: - Environment key (so child views can access the VM)

private struct NotificationLogViewModelKey: EnvironmentKey {
    static let defaultValue: NotificationLogViewModel? = nil
}

public extension EnvironmentValues {
    var notificationLogViewModel: NotificationLogViewModel? {
        get { self[NotificationLogViewModelKey.self] }
        set { self[NotificationLogViewModelKey.self] = newValue }
    }
}

// MARK: - Convenience button modifier

/// Adds an overlay button that shows the notification log with an unread badge.
public struct NotificationLogButton: View {
    @Environment(\.notificationLogViewModel) private var viewModel

    public init() {}

    public var body: some View {
        if let vm = viewModel {
            Button {
                vm.showLog()
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)

                    if vm.unread.count > 0 {
                        Text(vm.unread.count > 9 ? "9+" : "\(vm.unread.count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.red, in: Capsule())
                            .offset(x: 8, y: -6)
                    }
                }
            }
        }
    }
}
