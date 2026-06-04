//
//  FeedbackService.swift
//  NotificationLog
//
//  Created by Riley Koo on 6/4/26.
//


import Foundation

public final class FeedbackService {
    private let config: NotificationLogConfig
    private let session: URLSession
    private let feedbackTable = "feedback"

    public init(config: NotificationLogConfig) {
        self.config = config
        self.session = URLSession.shared
    }

    // MARK: - Post feedback (consumer apps)

    public func postFeedback(_ payload: NewFeedbackPayload) async throws {
        let url = URL(string: config.supabaseURL + "/rest/v1/\(feedbackTable)")!
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

    // MARK: - Fetch feedback (admin app — needs service role key)

    public func fetchFeedback(for appID: String) async throws -> [AppFeedback] {
        var components = URLComponents(string: config.supabaseURL + "/rest/v1/\(feedbackTable)")!
        components.queryItems = [
            URLQueryItem(name: "app_id", value: "eq.\(appID)"),
            URLQueryItem(name: "order", value: "date_added.desc"),
            URLQueryItem(name: "select", value: "*")
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(config.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
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
        return try decoder.decode([AppFeedback].self, from: data)
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