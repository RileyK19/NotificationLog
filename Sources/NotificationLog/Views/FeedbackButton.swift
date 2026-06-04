//
//  FeedbackButton.swift
//  NotificationLog
//
//  Created by Riley Koo on 6/4/26.
//


import SwiftUI

/// A button that presents the feedback sheet.
/// Place anywhere in your view hierarchy below `.notificationLog(config:)` —
/// it automatically picks up the config from the environment.
///
/// Usage:
/// ```swift
/// .toolbar {
///     ToolbarItem(placement: .navigationBarTrailing) {
///         FeedbackButton()
///     }
/// }
/// ```
public struct FeedbackButton: View {
    @Environment(\.notificationLogViewModel) private var viewModel
    @State private var isShowingFeedback = false

    public init() {}

    public var body: some View {
        if let vm = viewModel {
            Button {
                isShowingFeedback = true
            } label: {
                Image(systemName: "flag.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.primary)
            }
            .sheet(isPresented: $isShowingFeedback) {
                FeedbackSheetView(config: vm.config)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}