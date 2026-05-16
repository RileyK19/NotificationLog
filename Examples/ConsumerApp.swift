import SwiftUI
import NotificationLog

@main
struct MyExampleApp: App {

    static let notifConfig = NotificationLogConfig(
        supabaseURL: "https://YOUR_PROJECT.supabase.co",
        supabaseAnonKey: "YOUR_ANON_KEY",
        appID: "com.example.myapp",
        pollInterval: 60
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .notificationLog(config: MyExampleApp.notifConfig)
        }
    }
}

struct ContentView: View {
    @Environment(\.notificationLogViewModel) private var notifVM

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("My App")
                    .font(.largeTitle.bold())

                // Built-in button with unread badge
                NotificationLogButton()

                // Or wire your own button
                if let vm = notifVM {
                    Button("What's New (\(vm.unread.count))") {
                        vm.showLog()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NotificationLogButton()
                }
            }
        }
    }
}
