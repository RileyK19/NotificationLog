# NotificationLog

A zero-dependency Swift package that adds a notification log sheet to any SwiftUI app. Fetches notifications from Supabase by `appID`, auto-shows the sheet on new entries, tracks read state locally, and includes a badge button — all in one `.notificationLog(config:)` modifier.

---

## Setup

### 1. Add the package

In Xcode: **File → Add Package Dependencies** → paste your repo URL.

Or in `Package.swift`:
```swift
.package(url: "https://github.com/you/NotificationLog", from: "1.0.0")
```

### 2. Create the Supabase table

Run `supabase_schema.sql` in your Supabase Dashboard → SQL Editor.

```sql
-- The key table shape:
create table notifications (
    notification_id  uuid primary key default gen_random_uuid(),
    app_id           text        not null,
    title            text        not null,
    icon             text,          -- image URL
    thumbnail        text,          -- image URL  
    date_added       timestamptz not null default now(),
    details          jsonb          -- { description, image_url }
);
```

### 3. Attach the modifier

```swift
import NotificationLog

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .notificationLog(config: NotificationLogConfig(
                    supabaseURL: "https://xxx.supabase.co",
                    supabaseAnonKey: "your-anon-key",
                    appID: "com.example.myapp"
                ))
        }
    }
}
```

That's it. The sheet auto-appears when new notifications arrive.

---

## Configuration

```swift
NotificationLogConfig(
    supabaseURL:     "https://xxx.supabase.co",  // required
    supabaseAnonKey: "eyJ...",                   // required (anon key for reads)
    appID:           "com.example.myapp",         // required — filters by this
    pollInterval:    60,                          // seconds, nil = no polling
    tableName:       "notifications"              // override if needed
)
```

---

## Manual control

Access the ViewModel anywhere below the `.notificationLog` modifier:

```swift
@Environment(\.notificationLogViewModel) private var notifVM

// Show the log programmatically
Button("Updates") { notifVM?.showLog() }

// Check unread count
Text("\(notifVM?.unread.count ?? 0) unread")

// Manual refresh
await notifVM?.refresh()
```

### Built-in bell button (with badge)

```swift
// In a toolbar:
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        NotificationLogButton()
    }
}
```

---

## Posting notifications (Admin / Companion App)

Use `NotificationLogService` with your **service role key** (never ship in client apps):

```swift
let service = NotificationLogService(config: NotificationLogConfig(
    supabaseURL: "https://xxx.supabase.co",
    supabaseAnonKey: "YOUR_SERVICE_ROLE_KEY",  // ← service role for writes
    appID: "com.example.myapp"
))

try await service.postNotification(NewNotificationPayload(
    appID: "com.example.myapp",
    title: "New feature dropped 🎉",
    icon: "https://example.com/icon.png",
    details: NotificationDetails(
        description: "We just shipped dark mode. Check it out!",
        imageURL: "https://example.com/darkmode-hero.png"
    )
))
```

See `Examples/AdminApp.swift` for a full SwiftUI admin interface.

---

## Schema reference

| Column | Type | Notes |
|--------|------|-------|
| `notification_id` | `uuid` | PK, auto-generated |
| `app_id` | `text` | Filters per-app |
| `title` | `text` | Shown in list + detail header |
| `icon` | `text?` | URL, shown as app icon |
| `thumbnail` | `text?` | URL, shown in list row |
| `date_added` | `timestamptz` | Defaults to `now()` |
| `details` | `jsonb?` | `{ description, image_url }` |

The `details` JSONB column is intentionally open — add more fields freely without migrations.

---

## Supabase RLS

The included schema uses:
- **Public read** — anon key can SELECT (safe for client apps)  
- **Service insert** — only service_role key can INSERT (keep in admin app only)

To allow anon inserts (e.g. user-generated notifications), swap the insert policy to `with check (true)`.
