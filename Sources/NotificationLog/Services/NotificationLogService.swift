import Foundation

// MARK: - Supabase REST client (no external dependencies)

public final class NotificationLogService {
    private let config: NotificationLogConfig
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(config: NotificationLogConfig) {
        self.config = config
        self.session = URLSession.shared
        self.decoder = {
            let d = JSONDecoder()
            d.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let str = try container.decode(String.self)
                let formatters: [ISO8601DateFormatter] = [
                    { let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]; return f }(),
                    { let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime]; return f }()
                ]
                for fmt in formatters {
                    if let date = fmt.date(from: str) { return date }
                }
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(str)")
            }
            return d
        }()
    }

    // MARK: - Fetch

    public func fetchNotifications() async throws -> [AppNotification] {
        var components = URLComponents(string: config.supabaseURL + "/rest/v1/\(config.tableName)")!
        components.queryItems = [
            URLQueryItem(name: "app_id", value: "eq.\(config.appID)"),
            URLQueryItem(name: "order", value: "date_added.desc"),
            URLQueryItem(name: "select", value: "*")
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(config.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        return try decoder.decode([AppNotification].self, from: data)
    }

    // MARK: - Post (admin / companion app)

    public func postNotification(_ payload: NewNotificationPayload) async throws {
        let url = URL(string: config.supabaseURL + "/rest/v1/\(config.tableName)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(config.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(payload)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
    }

    // MARK: - Helpers

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NotificationLogError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw NotificationLogError.httpError(statusCode: http.statusCode, body: body)
        }
    }
}

// MARK: - Post payload

public struct NewNotificationPayload: Codable {
    public let appID: String
    public let title: String
    public let icon: String?
    public let thumbnail: String?
    public let details: NotificationDetails?

    public init(
        appID: String,
        title: String,
        icon: String? = nil,
        thumbnail: String? = nil,
        details: NotificationDetails? = nil
    ) {
        self.appID = appID
        self.title = title
        self.icon = icon
        self.thumbnail = thumbnail
        self.details = details
    }

    enum CodingKeys: String, CodingKey {
        case appID = "app_id"
        case title
        case icon
        case thumbnail
        case details
    }
}

// MARK: - Errors

public enum NotificationLogError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, body: String)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid server response"
        case .httpError(let code, let body): return "HTTP \(code): \(body)"
        }
    }
}
