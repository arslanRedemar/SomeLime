//
//  FirestoreReadTests.swift
//  SomlimeeTests
//
//  Integration tests for FirebaseDataSource read operations against the Firestore Emulator.
//

@testable import Somlimee
import XCTest
import FirebaseAuth
import FirebaseFirestore

final class FirestoreReadTests: FirestoreEmulatorTestBase {

    // MARK: - getLimeTrendsData

    func testGetLimeTrendsData() async throws {
        // Seed
        try await seedDocument(
            collection: "RealTime",
            document: "RTLimeTrends",
            data: ["List": ["trend1", "trend2", "trend3"]]
        )

        // Act
        let result = try await dataSource.getLimeTrendsData()

        // Assert
        XCTAssertNotNil(result)
        let list = result?["List"] as? [String]
        XCTAssertEqual(list, ["trend1", "trend2", "trend3"])
    }

    func testGetLimeTrendsData_noDocument() async throws {
        // Act — no seeding
        let result = try await dataSource.getLimeTrendsData()

        // Assert — document exists but has no data → nil
        XCTAssertNil(result)
    }

    // MARK: - getUserData

    func testGetUserData() async throws {
        // Seed user document keyed by the test UID
        try await seedDocument(
            collection: "Users",
            document: testUID,
            data: [
                "UserName": "IntegrationTestUser",
                "SignUpDate": "2025-01-01",
                "Points": 100,
                "NumOfPosts": 5,
                "ReceivedUps": 3,
                "DaysOfActive": 30,
                "PersonalityType": "SDR",
                "PersonalityTestResult": [10, 20, 30, 40]
            ]
        )

        // Act
        let result = try await dataSource.getUserData()

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?["UserName"] as? String, "IntegrationTestUser")
        XCTAssertEqual(result?["Points"] as? Int, 100)
        XCTAssertEqual(result?["PersonalityType"] as? String, "SDR")
    }

    func testGetUserData_notLoggedIn() async throws {
        // Sign out so there's no current user
        try Auth.auth().signOut()

        // Act
        let result = try await dataSource.getUserData()

        // Assert
        XCTAssertNil(result)

        // Re-sign in for tearDown cleanup
        try await signInAsPrimaryUser()
    }

    // MARK: - isUserLoggedIn

    func testIsUserLoggedIn_true() async throws {
        let result = try await dataSource.isUserLoggedIn()
        XCTAssertTrue(result)
    }

    func testIsUserLoggedIn_false() async throws {
        try Auth.auth().signOut()
        let result = try await dataSource.isUserLoggedIn()
        XCTAssertFalse(result)
        // Re-sign in
        try await signInAsPrimaryUser()
    }

    // MARK: - getBoardInfoData

    func testGetBoardInfoData() async throws {
        try await seedDocument(
            collection: "BoardInfo",
            document: "SDR",
            data: [
                "BoardOwnerId": "owner1",
                "BoardTapList": ["General", "Hot"],
                "BoardLevel": 1,
                "BoardDescription": "SDR Board Description",
                "BoardHotKeywords": ["keyword1", "keyword2"]
            ]
        )

        let result = try await dataSource.getBoardInfoData(boardName: "SDR")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?["BoardDescription"] as? String, "SDR Board Description")
        XCTAssertEqual(result?["BoardLevel"] as? Int, 1)
        let tapList = result?["BoardTapList"] as? [String]
        XCTAssertEqual(tapList, ["General", "Hot"])
    }

    func testGetBoardInfoData_emptyName() async throws {
        let result = try await dataSource.getBoardInfoData(boardName: "")
        XCTAssertNil(result)
    }

    func testGetBoardInfoData_nonExistent() async throws {
        let result = try await dataSource.getBoardInfoData(boardName: "NONEXISTENT")
        XCTAssertNil(result)
    }

    // MARK: - getBoardPostMetaList

    func testGetBoardPostMetaList_noFilter() async throws {
        // Seed 3 posts with different timestamps
        for i in 1...3 {
            try await seedDocumentAtPath(
                "BoardInfo/SDR/Posts/post\(i)",
                data: [
                    "PostTitle": "Post \(i)",
                    "PostType": "text",
                    "BoardTap": "General",
                    "UserId": testUID!,
                    "UserName": "TestUser",
                    "Views": i * 10,
                    "VoteUps": i,
                    "CommentsNumber": 0,
                    "PublishedTime": "2025-01-0\(i) 00:00:00 +0000"
                ]
            )
        }

        let result = try await dataSource.getBoardPostMetaList(
            boardName: "SDR",
            startTime: nil,
            counts: 10
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 3)

        // Verify descending order by PublishedTime
        let titles = result?.compactMap { $0["PostTitle"] as? String }
        XCTAssertEqual(titles, ["Post 3", "Post 2", "Post 1"])

        // Verify PostId is injected
        let postIds = result?.compactMap { $0["PostId"] as? String }
        XCTAssertTrue(postIds?.contains("post1") ?? false)
    }

    func testGetBoardPostMetaList_withStartTime() async throws {
        // Seed posts
        try await seedDocumentAtPath("BoardInfo/SDR/Posts/old", data: [
            "PostTitle": "Old Post",
            "PublishedTime": "2024-01-01 00:00:00 +0000",
            "PostType": "text", "BoardTap": "General",
            "UserId": testUID!, "UserName": "T", "Views": 0, "VoteUps": 0, "CommentsNumber": 0
        ])
        try await seedDocumentAtPath("BoardInfo/SDR/Posts/new", data: [
            "PostTitle": "New Post",
            "PublishedTime": "2025-06-01 00:00:00 +0000",
            "PostType": "text", "BoardTap": "General",
            "UserId": testUID!, "UserName": "T", "Views": 0, "VoteUps": 0, "CommentsNumber": 0
        ])

        let result = try await dataSource.getBoardPostMetaList(
            boardName: "SDR",
            startTime: "2025-01-01 00:00:00 +0000",
            counts: 10
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?["PostTitle"] as? String, "New Post")
    }

    func testGetBoardPostMetaList_limit() async throws {
        for i in 1...3 {
            try await seedDocumentAtPath("BoardInfo/SDR/Posts/post\(i)", data: [
                "PostTitle": "Post \(i)",
                "PublishedTime": "2025-01-0\(i) 00:00:00 +0000",
                "PostType": "text", "BoardTap": "General",
                "UserId": testUID!, "UserName": "T", "Views": 0, "VoteUps": 0, "CommentsNumber": 0
            ])
        }

        let result = try await dataSource.getBoardPostMetaList(
            boardName: "SDR",
            startTime: nil,
            counts: 1
        )

        XCTAssertEqual(result?.count, 1)
    }

    func testGetBoardPostMetaList_emptyBoard() async throws {
        let result = try await dataSource.getBoardPostMetaList(
            boardName: "",
            startTime: nil,
            counts: 10
        )
        XCTAssertNil(result)
    }

    func testGetBoardPostMetaList_zeroCounts() async throws {
        let result = try await dataSource.getBoardPostMetaList(
            boardName: "SDR",
            startTime: nil,
            counts: 0
        )
        XCTAssertNil(result)
    }

    // MARK: - getBoardHotPostsList

    func testGetBoardHotPostsList() async throws {
        for i in 1...3 {
            try await seedDocumentAtPath("BoardHotPosts/SDR/Posts/hot\(i)", data: [
                "PublishedTime": "2025-01-0\(i) 00:00:00 +0000"
            ])
        }

        let result = try await dataSource.getBoardHotPostsList(
            boardName: "SDR",
            startTime: nil,
            counts: 10
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 3)
        XCTAssertTrue(result?.contains("hot1") ?? false)
        XCTAssertTrue(result?.contains("hot2") ?? false)
        XCTAssertTrue(result?.contains("hot3") ?? false)
    }

    // MARK: - getBoardPostMeta

    func testGetBoardPostMeta() async throws {
        try await seedDocumentAtPath("BoardInfo/SDR/Posts/post1", data: [
            "PostTitle": "Specific Post",
            "PostType": "image",
            "BoardTap": "Hot",
            "UserId": testUID!,
            "UserName": "TestUser",
            "Views": 42,
            "VoteUps": 7,
            "CommentsNumber": 3,
            "PublishedTime": "2025-02-15 12:00:00 +0000"
        ])

        let result = try await dataSource.getBoardPostMeta(boardName: "SDR", postId: "post1")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?["PostTitle"] as? String, "Specific Post")
        XCTAssertEqual(result?["PostType"] as? String, "image")
        XCTAssertEqual(result?["Views"] as? Int, 42)
        XCTAssertEqual(result?["VoteUps"] as? Int, 7)
    }

    func testGetBoardPostMeta_nonExistent() async throws {
        let result = try await dataSource.getBoardPostMeta(boardName: "SDR", postId: "nope")
        XCTAssertNil(result)
    }

    // MARK: - getBoardPostContent

    func testGetBoardPostContent() async throws {
        let basePath = "BoardInfo/SDR/Posts/post1/BoardPostContents"
        try await seedDocumentAtPath("\(basePath)/Paragraph", data: [
            "Text": "Hello world paragraph"
        ])
        try await seedDocumentAtPath("\(basePath)/Image", data: [
            "URLs": ["https://example.com/img1.jpg"]
        ])
        try await seedDocumentAtPath("\(basePath)/Video", data: [
            "URLs": [String]()
        ])
        try await seedDocumentAtPath("\(basePath)/Comments", data: [
            "Count": 2
        ])

        let result = try await dataSource.getBoardPostContent(boardName: "SDR", postId: "post1")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 4)

        // Index 0 = Paragraph
        XCTAssertEqual(result?[0]["Text"] as? String, "Hello world paragraph")
        // Index 1 = Image
        let imageURLs = result?[1]["URLs"] as? [String]
        XCTAssertEqual(imageURLs, ["https://example.com/img1.jpg"])
        // Index 2 = Video
        let videoURLs = result?[2]["URLs"] as? [String]
        XCTAssertEqual(videoURLs, [])
        // Index 3 = Comments
        XCTAssertEqual(result?[3]["Count"] as? Int, 2)
    }

    func testGetBoardPostContent_emptyBoardName() async throws {
        let result = try await dataSource.getBoardPostContent(boardName: "", postId: "post1")
        XCTAssertNil(result)
    }

    func testGetBoardPostContent_emptyPostId() async throws {
        let result = try await dataSource.getBoardPostContent(boardName: "SDR", postId: "")
        XCTAssertNil(result)
    }

    // MARK: - getComments

    func testGetComments() async throws {
        let commentBase = "BoardInfo/SDR/Posts/post1/BoardPostContents/Comments/CommentList"
        try await seedDocumentAtPath("\(commentBase)/c1", data: [
            "Text": "First comment",
            "UserName": "User1",
            "UserId": "uid1",
            "PostId": "post1",
            "Target": "",
            "PublishedTime": "2025-01-01 00:00:00 +0000",
            "IsRevised": "No"
        ])
        try await seedDocumentAtPath("\(commentBase)/c2", data: [
            "Text": "Second comment",
            "UserName": "User2",
            "UserId": "uid2",
            "PostId": "post1",
            "Target": "",
            "PublishedTime": "2025-01-02 00:00:00 +0000",
            "IsRevised": "No"
        ])

        let result = try await dataSource.getComments(boardName: "SDR", postId: "post1")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)

        // Ascending order by PublishedTime
        XCTAssertEqual(result?.first?["Text"] as? String, "First comment")
        XCTAssertEqual(result?.last?["Text"] as? String, "Second comment")

        // PostId is injected
        XCTAssertEqual(result?.first?["PostId"] as? String, "post1")
    }

    func testGetComments_emptyInputs() async throws {
        let result1 = try await dataSource.getComments(boardName: "", postId: "post1")
        XCTAssertNil(result1)

        let result2 = try await dataSource.getComments(boardName: "SDR", postId: "")
        XCTAssertNil(result2)
    }

    // MARK: - getUserPosts

    func testGetUserPosts() async throws {
        // Seed posts by our test user in two different boards
        try await seedDocumentAtPath("BoardInfo/SDR/Posts/p1", data: [
            "PostTitle": "SDR Post",
            "UserId": testUID!,
            "UserName": "TestUser",
            "PublishedTime": "2025-01-01 00:00:00 +0000",
            "PostType": "text", "BoardTap": "General", "Views": 0, "VoteUps": 0, "CommentsNumber": 0
        ])
        try await seedDocumentAtPath("BoardInfo/HDE/Posts/p2", data: [
            "PostTitle": "HDE Post",
            "UserId": testUID!,
            "UserName": "TestUser",
            "PublishedTime": "2025-02-01 00:00:00 +0000",
            "PostType": "text", "BoardTap": "General", "Views": 0, "VoteUps": 0, "CommentsNumber": 0
        ])
        // A post by a different user — should NOT appear
        try await seedDocumentAtPath("BoardInfo/SDR/Posts/p3", data: [
            "PostTitle": "Other User Post",
            "UserId": "different-uid",
            "UserName": "Other",
            "PublishedTime": "2025-03-01 00:00:00 +0000",
            "PostType": "text", "BoardTap": "General", "Views": 0, "VoteUps": 0, "CommentsNumber": 0
        ])

        let result = try await dataSource.getUserPosts(userId: testUID)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)

        // BoardName should be injected
        let boardNames = result?.compactMap { $0["BoardName"] as? String }.sorted()
        XCTAssertTrue(boardNames?.contains("SDR") ?? false)
        XCTAssertTrue(boardNames?.contains("HDE") ?? false)

        // PostId should be injected
        let postIds = result?.compactMap { $0["PostId"] as? String }.sorted()
        XCTAssertTrue(postIds?.contains("p1") ?? false)
        XCTAssertTrue(postIds?.contains("p2") ?? false)
    }

    func testGetUserPosts_emptyUserId() async throws {
        let result = try await dataSource.getUserPosts(userId: "")
        XCTAssertNil(result)
    }

    // MARK: - getUserComments

    func testGetUserComments() async throws {
        // First seed a post, then add a comment by our test user
        try await seedDocumentAtPath("BoardInfo/SDR/Posts/p1", data: [
            "PostTitle": "Post", "UserId": "someone", "UserName": "X",
            "PublishedTime": "2025-01-01", "PostType": "text",
            "BoardTap": "General", "Views": 0, "VoteUps": 0, "CommentsNumber": 1
        ])
        try await seedDocumentAtPath(
            "BoardInfo/SDR/Posts/p1/BoardPostContents/Comments/CommentList/c1",
            data: [
                "Text": "My comment",
                "UserName": "TestUser",
                "UserId": testUID!,
                "PostId": "p1",
                "Target": "",
                "PublishedTime": "2025-01-02 00:00:00 +0000",
                "IsRevised": "No"
            ]
        )

        let result = try await dataSource.getUserComments(userId: testUID)

        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(result?.count ?? 0, 1)

        let firstComment = result?.first(where: { ($0["Text"] as? String) == "My comment" })
        XCTAssertNotNil(firstComment)
        XCTAssertEqual(firstComment?["BoardName"] as? String, "SDR")
        XCTAssertEqual(firstComment?["PostId"] as? String, "p1")
    }

    // MARK: - getNotifications

    func testGetNotifications() async throws {
        // Seed notifications for our test user
        for i in 1...3 {
            try await seedDocumentAtPath("Notifications/\(testUID!)/items/n\(i)", data: [
                "title": "Notification \(i)",
                "body": "Body \(i)",
                "timestamp": "2025-01-0\(i) 00:00:00 +0000",
                "isRead": false
            ])
        }

        let result = try await dataSource.getNotifications(limit: 10)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 3)

        // Descending order by timestamp
        let titles = result?.compactMap { $0["title"] as? String }
        XCTAssertEqual(titles?.first, "Notification 3")

        // id should be injected
        let ids = result?.compactMap { $0["id"] as? String }
        XCTAssertTrue(ids?.contains("n1") ?? false)
    }

    func testGetNotifications_limit() async throws {
        for i in 1...5 {
            try await seedDocumentAtPath("Notifications/\(testUID!)/items/n\(i)", data: [
                "title": "Notification \(i)",
                "timestamp": "2025-01-0\(i) 00:00:00 +0000",
                "isRead": false
            ])
        }

        let result = try await dataSource.getNotifications(limit: 2)

        XCTAssertEqual(result?.count, 2)
    }

    func testGetNotifications_notLoggedIn() async throws {
        try Auth.auth().signOut()
        let result = try await dataSource.getNotifications(limit: 10)
        XCTAssertNil(result)
        try await signInAsPrimaryUser()
    }

    // MARK: - Timestamp Conversion

    func testTimestampConversion() async throws {
        // Seed with a Firestore Timestamp object
        let date = Date(timeIntervalSince1970: 1700000000)
        let timestamp = Timestamp(date: date)
        try await seedDocument(
            collection: "Users",
            document: testUID,
            data: [
                "UserName": "TimestampTest",
                "SignUpDate": timestamp
            ]
        )

        let result = try await dataSource.getUserData()

        XCTAssertNotNil(result)
        // convertTimestamps should have turned the Timestamp into a String
        let signUpDate = result?["SignUpDate"]
        XCTAssertTrue(signUpDate is String, "Expected Timestamp to be converted to String, got \(type(of: signUpDate as Any))")
        // The string should contain the year 2023 (timestamp 1700000000 = Nov 14, 2023)
        let dateString = signUpDate as? String ?? ""
        XCTAssertTrue(dateString.contains("2023"), "Expected date string to contain '2023', got: \(dateString)")
    }
}
