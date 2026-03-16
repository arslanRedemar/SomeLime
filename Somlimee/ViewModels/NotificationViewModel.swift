//
//  NotificationViewModel.swift
//  Somlimee
//

import Foundation

protocol NotificationViewModel {
    var notifications: [AppNotification] { get }
    var unreadCount: Int { get }
    var errorMessage: String? { get }
    var isLoading: Bool { get }
    func loadNotifications() async
    func markAsRead(id: String) async
    func markAllAsRead() async
}

@Observable
final class NotificationViewModelImpl: NotificationViewModel {
    var notifications: [AppNotification] = []
    var unreadCount: Int = 0
    var errorMessage: String?
    var isLoading = false

    private let notificationRepo: NotificationRepository

    init(notificationRepo: NotificationRepository) {
        self.notificationRepo = notificationRepo
    }

    func loadNotifications() async {
        Log.vm.debug("NotificationViewModel.loadNotifications: start")
        isLoading = true
        defer { isLoading = false }
        do {
            notifications = try await notificationRepo.getNotifications(limit: 50)
            unreadCount = notifications.filter { !$0.isRead }.count
            errorMessage = nil
            Log.vm.debug("NotificationViewModel.loadNotifications: success — \(self.notifications.count) notifications, \(self.unreadCount) unread")
        } catch {
            Log.vm.error("NotificationViewModel.loadNotifications: failed — \(error)")
            errorMessage = "알림을 불러올 수 없습니다"
        }
    }

    func markAsRead(id: String) async {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        Log.vm.info("NotificationViewModel.markAsRead: id=\(id)")
        do {
            try await notificationRepo.markAsRead(id: id)
            notifications[index].isRead = true
            unreadCount = notifications.filter { !$0.isRead }.count
            Log.vm.info("NotificationViewModel.markAsRead: success")
        } catch {
            Log.vm.error("NotificationViewModel.markAsRead: failed — \(error)")
            errorMessage = "알림 상태를 업데이트할 수 없습니다"
        }
    }

    func markAllAsRead() async {
        Log.vm.info("NotificationViewModel.markAllAsRead: user action")
        for i in notifications.indices where !notifications[i].isRead {
            do {
                try await notificationRepo.markAsRead(id: notifications[i].id)
                notifications[i].isRead = true
            } catch {
                Log.vm.error("NotificationViewModel.markAllAsRead: failed for notification \(i) — \(error)")
                // Continue marking remaining notifications
            }
        }
        unreadCount = 0
        Log.vm.info("NotificationViewModel.markAllAsRead: completed")
    }
}
