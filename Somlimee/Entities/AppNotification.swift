//
//  AppNotification.swift
//  Somlimee
//

import Foundation

struct AppNotification: Identifiable {
    let id: String
    let type: NotificationType
    let senderName: String
    let message: String
    let boardName: String?
    let postId: String?
    let timestamp: String
    var isRead: Bool

    enum NotificationType: String {
        case comment, reply, upvote, mention
    }
}
