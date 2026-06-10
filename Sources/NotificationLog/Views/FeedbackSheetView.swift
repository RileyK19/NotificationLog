//
//  FeedbackSheetView.swift
//  NotificationLog
//
//  Created by Riley Koo on 6/4/26.
//


import SwiftUI

struct FeedbackSheetView: View {
    let config: NotificationLogConfig
    @Environment(\.dismiss) private var dismiss

    @State private var type: FeedbackType = .bug
    @State private var title = ""
    @State private var description = ""
    @State private var senderName = ""
    @State private var isSending = false
    @State private var didSend = false
    @State private var errorMessage: String?

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    private var deviceInfo: String {
        UIDevice.current.systemName + " " + UIDevice.current.systemVersion
    }

    var body: some View {
        NavigationStack {
            Form {
                // Type picker
                Section {
                    Picker("Type", selection: $type) {
                        ForEach(FeedbackType.allCases, id: \.self) { t in
                            Label(t.label, systemImage: t.icon).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.clear)

                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(4...)
                }

                Section("Your name (optional)") {
                    TextField("Name", text: $senderName)
                        .autocorrectionDisabled()
                }

                if let err = errorMessage {
                    Section {
                        Text(err)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task { await submit() }
                    } label: {
                        if isSending {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Submit").frame(maxWidth: .infinity).bold()
                        }
                    }
                    .disabled(title.isEmpty || isSending)
                }
            }
            .navigationTitle(type.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if didSend { successOverlay }
            }
        }
    }

    // MARK: - Success overlay

    private var successOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            Text("Thanks for the feedback!")
                .font(.headline)
            Text("We appreciate you taking the time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }

    // MARK: - Submit

    private func submit() async {
        isSending = true
        errorMessage = nil
        let service = FeedbackService(config: config)
        let payload = NewFeedbackPayload(
            appID: config.appID,
            type: type,
            title: title,
            description: description.isEmpty ? nil : description,
            senderName: senderName.isEmpty ? nil : senderName,
            appVersion: appVersion,
            deviceInfo: deviceInfo
        )
        do {
            try await service.postFeedback(payload)
            didSend = true
            try? await Task.sleep(for: .seconds(1.8))
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSending = false
    }
}

#Preview {
    FeedbackSheetView(config: NotificationLogConfig(
        supabaseURL: "https://example.supabase.co",
        supabaseAnonKey: "key",
        appID: "com.example.preview"
    ))
}
