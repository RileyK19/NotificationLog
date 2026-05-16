import SwiftUI
import NotificationLog

// Use your Supabase SERVICE ROLE key here for insert access.
// Never ship this key in a user-facing app.

@main
struct NotificationAdminApp: App {
    var body: some Scene {
        WindowGroup { AdminView() }
    }
}

struct AdminView: View {
    @State private var targetAppID = "com.example.myapp"
    @State private var title = ""
    @State private var description = ""
    @State private var iconURL = ""
    @State private var thumbnailURL = ""
    @State private var imageURL = ""
    @State private var isSending = false
    @State private var resultMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Target App") {
                    TextField("App ID", text: $targetAppID)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                Section("Notification") {
                    TextField("Title *", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...)
                }
                Section("Images (optional)") {
                    TextField("Icon URL", text: $iconURL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Thumbnail URL", text: $thumbnailURL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Detail Image URL", text: $imageURL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                Section {
                    Button {
                        Task { await send() }
                    } label: {
                        if isSending {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Send Notification").frame(maxWidth: .infinity).bold()
                        }
                    }
                    .disabled(title.isEmpty || targetAppID.isEmpty || isSending)
                }
                if let msg = resultMessage {
                    Section("Result") {
                        Text(msg)
                            .font(.caption)
                            .foregroundStyle(msg.hasPrefix("✅") ? .green : .red)
                    }
                }
            }
            .navigationTitle("Notification Admin")
        }
    }

    private func send() async {
        isSending = true
        resultMessage = nil
        let service = NotificationLogService(config: NotificationLogConfig(
            supabaseURL: "https://YOUR_PROJECT.supabase.co",
            supabaseAnonKey: "YOUR_SERVICE_ROLE_KEY",
            appID: targetAppID
        ))
        let payload = NewNotificationPayload(
            appID: targetAppID,
            title: title,
            icon: iconURL.isEmpty ? nil : iconURL,
            thumbnail: thumbnailURL.isEmpty ? nil : thumbnailURL,
            details: (description.isEmpty && imageURL.isEmpty) ? nil :
                NotificationDetails(
                    description: description.isEmpty ? nil : description,
                    imageURL: imageURL.isEmpty ? nil : imageURL
                )
        )
        do {
            try await service.postNotification(payload)
            resultMessage = "✅ Sent to \(targetAppID)"
            title = ""; description = ""
        } catch {
            resultMessage = "❌ \(error.localizedDescription)"
        }
        isSending = false
    }
}
