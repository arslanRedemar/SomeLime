//
//  NotificationData.swift
//  Somlimee
//

import Foundation

struct NotificationData: Codable {
    let type: String
    let senderName: String
    let message: String
    let boardName: String?
    let postId: String?
    let timestamp: String
    var isRead: Bool
}
