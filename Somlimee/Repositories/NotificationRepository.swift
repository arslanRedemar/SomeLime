//
//  NotificationRepository.swift
//  Somlimee
//

import Foundation

protocol NotificationRepository {
    func getNotifications(limit: Int) async throws -> [AppNotification]
    func markAsRead(id: String) async throws
}

class NotificationRepositoryImpl: NotificationRepository {
    private let dataSource: DataSource

    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    func getNotifications(limit: Int) async throws -> [AppNotification] {
        Log.repo.debug("[NotificationRepositoryImpl.getNotifications] Fetching notifications limit=\(limit)")
        do {
            guard let dataList = try await dataSource.getNotifications(limit: limit) else {
                Log.repo.debug("[NotificationRepositoryImpl.getNotifications] No notifications found")
                return []
            }
            let result: [AppNotification] = dataList.compactMap { data in
                guard let id = data["id"] as? String,
                      let typeStr = data["type"] as? String,
                      let type = AppNotification.NotificationType(rawValue: typeStr),
                      let senderName = data["senderName"] as? String,
                      let message = data["message"] as? String,
                      let timestamp = data["timestamp"] as? String else {
                    return nil
                }
                let isRead = (data["isRead"] as? Bool) ?? false
                let boardName = data["boardName"] as? String
                let postId = data["postId"] as? String
                return AppNotification(
                    id: id,
                    type: type,
                    senderName: senderName,
                    message: message,
                    boardName: boardName,
                    postId: postId,
                    timestamp: timestamp,
                    isRead: isRead
                )
            }
            Log.repo.debug("[NotificationRepositoryImpl.getNotifications] Successfully fetched \(result.count) notifications")
            return result
        } catch {
            Log.repo.error("[NotificationRepositoryImpl.getNotifications] Failed — \(error.localizedDescription)")
            throw error
        }
    }

    func markAsRead(id: String) async throws {
        Log.repo.info("[NotificationRepositoryImpl.markAsRead] Marking notification as read id=\(id)")
        do {
            try await dataSource.markNotificationRead(notificationId: id)
            Log.repo.info("[NotificationRepositoryImpl.markAsRead] Successfully marked notification as read")
        } catch {
            Log.repo.error("[NotificationRepositoryImpl.markAsRead] Failed for id=\(id) — \(error.localizedDescription)")
            throw error
        }
    }
}
