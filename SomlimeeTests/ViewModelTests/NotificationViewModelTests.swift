@testable import Somlimee
import XCTest

final class NotificationViewModelTests: XCTestCase {

    private var mockRepo: MockNotificationRepository!
    private var sut: NotificationViewModelImpl!

    override func setUp() {
        super.setUp()
        mockRepo = MockNotificationRepository()
        sut = NotificationViewModelImpl(notificationRepo: mockRepo)
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - loadNotifications

    func testLoadNotifications_setsNotificationsAndUnreadCount() async {
        mockRepo.getNotificationsResult = [
            AppNotification(id: "1", type: .comment, senderName: "Alice", message: "댓글을 남겼습니다", boardName: "SDR", postId: "p1", timestamp: "2026-02-16", isRead: false),
            AppNotification(id: "2", type: .upvote, senderName: "Bob", message: "추천했습니다", boardName: "HDE", postId: "p2", timestamp: "2026-02-15", isRead: true)
        ]

        await sut.loadNotifications()

        XCTAssertEqual(sut.notifications.count, 2)
        XCTAssertEqual(sut.unreadCount, 1)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockRepo.getNotificationsCallCount, 1)
    }

    func testLoadNotifications_emptyList() async {
        mockRepo.getNotificationsResult = []

        await sut.loadNotifications()

        XCTAssertTrue(sut.notifications.isEmpty)
        XCTAssertEqual(sut.unreadCount, 0)
    }

    // MARK: - markAsRead

    func testMarkAsRead_updatesNotificationAndUnreadCount() async {
        mockRepo.getNotificationsResult = [
            AppNotification(id: "1", type: .comment, senderName: "Alice", message: "test", boardName: "SDR", postId: "p1", timestamp: "2026-02-16", isRead: false),
            AppNotification(id: "2", type: .reply, senderName: "Bob", message: "test2", boardName: "HDE", postId: "p2", timestamp: "2026-02-15", isRead: false)
        ]
        await sut.loadNotifications()
        XCTAssertEqual(sut.unreadCount, 2)

        await sut.markAsRead(id: "1")

        XCTAssertTrue(sut.notifications[0].isRead)
        XCTAssertFalse(sut.notifications[1].isRead)
        XCTAssertEqual(sut.unreadCount, 1)
        XCTAssertEqual(mockRepo.markAsReadCallCount, 1)
        XCTAssertEqual(mockRepo.lastMarkAsReadId, "1")
    }

    func testMarkAsRead_nonexistentId_doesNothing() async {
        mockRepo.getNotificationsResult = [
            AppNotification(id: "1", type: .comment, senderName: "Alice", message: "test", boardName: nil, postId: nil, timestamp: "2026-02-16", isRead: false)
        ]
        await sut.loadNotifications()

        await sut.markAsRead(id: "nonexistent")

        XCTAssertEqual(mockRepo.markAsReadCallCount, 0)
        XCTAssertEqual(sut.unreadCount, 1)
    }

    // MARK: - markAllAsRead

    func testMarkAllAsRead_marksAllAndResetsCount() async {
        mockRepo.getNotificationsResult = [
            AppNotification(id: "1", type: .comment, senderName: "A", message: "m1", boardName: "SDR", postId: "p1", timestamp: "t1", isRead: false),
            AppNotification(id: "2", type: .upvote, senderName: "B", message: "m2", boardName: "HDE", postId: "p2", timestamp: "t2", isRead: false),
            AppNotification(id: "3", type: .mention, senderName: "C", message: "m3", boardName: nil, postId: nil, timestamp: "t3", isRead: true)
        ]
        await sut.loadNotifications()
        XCTAssertEqual(sut.unreadCount, 2)

        await sut.markAllAsRead()

        XCTAssertEqual(sut.unreadCount, 0)
        XCTAssertTrue(sut.notifications.allSatisfy { $0.isRead })
        XCTAssertEqual(mockRepo.markAsReadCallCount, 2) // only 2 were unread
    }
}
