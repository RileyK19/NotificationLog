//
//  AppFeedback.swift
//  NotificationLog
//
//  Created by Riley Koo on 6/4/26.
//


import Foundation

// MARK: - Feedback Model

public struct AppFeedback: Identifiable, Codable, Equatable {
    public let id: String
    public let appID: String
    public let type: FeedbackType
    public let title: String
    public let description: String?
    public let senderName: String?
    public let appVersion: String?
    public let deviceInfo: String?
    public let dateAdded: Date

    public init(
        id: String = UUID().uuidString,
        appID: String,
        type: FeedbackType,
        title: String,
        description: String? = nil,
        senderName: String? = nil,
        appVersion: String? = nil,
        deviceInfo: String? = nil,
        dateAdded: Date = .now
    ) {
        self.id = id
        self.appID = appID
        self.type = type
        self.title = title
        self.description = description
        self.senderName = senderName
        self.appVersion = appVersion
        self.deviceInfo = deviceInfo
        self.dateAdded = dateAdded
    }

    enum CodingKeys: String, CodingKey {
        case id = "feedback_id"
        case appID = "app_id"
        case type
        case title
        case description
        case senderName = "sender_name"
        case appVersion = "app_version"
        case deviceInfo = "device_info"
        case dateAdded = "date_added"
    }
}

public enum FeedbackType: String, Codable, CaseIterable {
    case bug
    case suggestion

    public var label: String {
        switch self {
        case .bug: return "Bug Report"
        case .suggestion: return "Suggestion"
        }
    }

    public var icon: String {
        switch self {
        case .bug: return "ant.fill"
        case .suggestion: return "lightbulb.fill"
        }
    }
}

// MARK: - Post Payload

public struct NewFeedbackPayload: Codable {
    public let appID: String
    public let type: FeedbackType
    public let title: String
    public let description: String?
    public let senderName: String?
    public let appVersion: String?
    public let deviceInfo: String?

    public init(
        appID: String,
        type: FeedbackType,
        title: String,
        description: String? = nil,
        senderName: String? = nil,
        appVersion: String? = nil,
        deviceInfo: String? = nil
    ) {
        self.appID = appID
        self.type = type
        self.title = title
        self.description = description
        self.senderName = senderName
        self.appVersion = appVersion
        self.deviceInfo = deviceInfo
    }

    enum CodingKeys: String, CodingKey {
        case appID = "app_id"
        case type
        case title
        case description
        case senderName = "sender_name"
        case appVersion = "app_version"
        case deviceInfo = "device_info"
    }
}