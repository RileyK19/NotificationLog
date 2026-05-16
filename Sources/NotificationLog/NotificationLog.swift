// NotificationLog — public API surface
// Import this package and use `.notificationLog(config:)` on your root view.

@_exported import Foundation

// All public types are in their respective files.
// This file exists to document the public API in one place.

/*
 ┌─────────────────────────────────────────────┐
 │           NOTIFICATIONLOG PACKAGE           │
 ├─────────────────────────────────────────────┤
 │  PUBLIC API                                  │
 │                                             │
 │  Config:                                    │
 │    NotificationLogConfig(                   │
 │      supabaseURL:    String,                 │
 │      supabaseAnonKey: String,               │
 │      appID:          String,                │
 │      pollInterval:   TimeInterval? = 60,    │
 │      tableName:      String = "notifications"│
 │    )                                        │
 │                                             │
 │  ViewModifier (attach to root view):        │
 │    .notificationLog(config:)                │
 │                                             │
 │  ViewModel (via environment):               │
 │    @Environment(\.notificationLogViewModel) │
 │    vm.showLog()     — show sheet            │
 │    vm.unread        — unread notifications  │
 │    vm.notifications — all notifications     │
 │    vm.refresh()     — manual refresh        │
 │                                             │
 │  Built-in bell button:                      │
 │    NotificationLogButton()                  │
 │    (place in .toolbar or anywhere)          │
 │                                             │
 │  Post notifications (admin/companion):      │
 │    NotificationLogService(config:)          │
 │      .postNotification(NewNotificationPayload)│
 └─────────────────────────────────────────────┘
*/
