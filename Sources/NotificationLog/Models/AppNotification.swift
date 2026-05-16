import Foundation

// MARK: - Core Models

public struct AppNotification: Identifiable, Codable, Equatable {
    public let id: String
    public let appID: String
    public let title: String
    public let icon: String?
    public let thumbnail: String?
    public let dateAdded: Date
    public let details: NotificationDetails?

    public init(
        id: String,
        appID: String,
        title: String,
        icon: String? = nil,
        thumbnail: String? = nil,
        dateAdded: Date = .now,
        details: NotificationDetails? = nil
    ) {
        self.id = id
        self.appID = appID
        self.title = title
        self.icon = icon
        self.thumbnail = thumbnail
        self.dateAdded = dateAdded
        self.details = details
    }

    enum CodingKeys: String, CodingKey {
        case id = "notification_id"
        case appID = "app_id"
        case title
        case icon
        case thumbnail
        case dateAdded = "date_added"
        case details
    }
}

public struct NotificationDetails: Codable, Equatable {
    public let description: String?
    public let imageURL: String?

    public init(description: String? = nil, imageURL: String? = nil) {
        self.description = description
        self.imageURL = imageURL
    }

    enum CodingKeys: String, CodingKey {
        case description
        case imageURL = "image_url"
    }
}

// MARK: - Configuration

public struct NotificationLogConfig {
    /// Your Supabase project URL
    public let supabaseURL: String
    /// Supabase anon/public key
    public let supabaseAnonKey: String
    /// The app identifier — only notifications with this app_id will be fetched
    public let appID: String
    /// How often (in seconds) to poll for new notifications. Default: 60s. Set nil to disable polling.
    public let pollInterval: TimeInterval?
    /// Table name in your Supabase DB. Default: "notifications"
    public let tableName: String

    public init(
        supabaseURL: String,
        supabaseAnonKey: String,
        appID: String,
        pollInterval: TimeInterval? = 60,
        tableName: String = "notifications"
    ) {
        self.supabaseURL = supabaseURL
        self.supabaseAnonKey = supabaseAnonKey
        self.appID = appID
        self.pollInterval = pollInterval
        self.tableName = tableName
    }
}
