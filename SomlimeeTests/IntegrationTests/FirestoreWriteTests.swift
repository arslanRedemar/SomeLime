//
//  FirestoreWriteTests.swift
//  SomlimeeTests
//
//  Integration tests for FirebaseDataSource write operations against the Firestore Emulator.
//

@testable import Somlimee
import XCTest
import FirebaseAuth
import FirebaseFirestore

final class FirestoreWriteTests: FirestoreEmulatorTestBase {

    // MARK: - createPost

    func testCreatePost() async throws {
        // Seed user so createPost can look up UserName
        try await seedDocument(collection: "Users", document: testUID, data: [
            "UserName": "PostAuthor"
        ])

        let postData = BoardPostContentData(
            boardPostTap: "General",
            boardPostUserId: testUID,
            boardPostTitle: "Integration Test Post",
            boardPostParagraph: "This is the paragraph content.",
            boardPostImageURLs: [],
            boardPostComments: []
        )

        // Act
        try await dataSource.createPost(boardName: "SDR", postData: postData)

        // Verify — query the Posts subcollection
        let postsSnapshot = try await db.collection("BoardInfo")
            .document("SDR").collection("Posts")
            .getDocuments()

        XCTAssertEqual(postsSnapshot.documents.count, 1)

        let postDoc = postsSnapshot.documents.first!
        let postFields = postDoc.data()
        XCTAssertEqual(postFields["PostTitle"] as? String, "Integration Test Post")
        XCTAssertEqual(postFields["UserName"] as? String, "PostAuthor")
        XCTAssertEqual(postFields["PostType"] as? String, "text")
        XCTAssertEqual(postFields["VoteUps"] as? Int, 0)
        XCTAssertEqual(postFields["Views"] as? Int, 0)
        XCTAssertEqual(postFields["CommentsNumber"] as? Int, 0)
        XCTAssertEqual(postFields["UserId"] as? String, testUID)

        // PublishedTime should be a server timestamp (Timestamp type in emulator)
        XCTAssertNotNil(postFields["PublishedTime"])

        // Verify subcollection documents (Paragraph, Image, Video)
        let postId = postDoc.documentID
        let contentsBase = db.collection("BoardInfo").document("SDR")
            .collection("Posts").document(postId)
            .collection("BoardPostContents")

        let paragraph = try await contentsBase.document("Paragraph").getDocument().data()
        XCTAssertEqual(paragraph?["Text"] as? String, "This is the paragraph content.")

        let image = try await contentsBase.document("Image").getDocument().data()
        let imageURLs = image?["URLs"] as? [String]
        XCTAssertEqual(imageURLs, [])

        let video = try await contentsBase.document("Video").getDocument().data()
        let videoURLs = video?["URLs"] as? [String]
        XCTAssertEqual(videoURLs, [])
    }

    func testCreatePost_withImages() async throws {
        try await seedDocument(collection: "Users", document: testUID, data: [
            "UserName": "ImagePoster"
        ])

        let postData = BoardPostContentData(
            boardPostTap: "Hot",
            boardPostUserId: testUID,
            boardPostTitle: "Image Post",
            boardPostParagraph: "Has images",
            boardPostImageURLs: ["https://example.com/a.jpg", "https://example.com/b.jpg"],
            boardPostComments: []
        )

        try await dataSource.createPost(boardName: "SDR", postData: postData)

        let postsSnapshot = try await db.collection("BoardInfo")
            .document("SDR").collection("Posts")
            .getDocuments()

        XCTAssertEqual(postsSnapshot.documents.count, 1)
        let postDoc = postsSnapshot.documents.first!
        // PostType should be "image" when imageURLs is non-empty
        XCTAssertEqual(postDoc.data()["PostType"] as? String, "image")

        let contentsBase = postDoc.reference.collection("BoardPostContents")
        let image = try await contentsBase.document("Image").getDocument().data()
        let urls = image?["URLs"] as? [String]
        XCTAssertEqual(urls?.count, 2)
    }

    func testCreatePost_emptyBoardName() async throws {
        let postData = BoardPostContentData(
            boardPostTap: "General",
            boardPostUserId: testUID,
            boardPostTitle: "Should Not Create",
            boardPostParagraph: "text",
            boardPostImageURLs: [],
            boardPostComments: []
        )

        // Should return early without error
        try await dataSource.createPost(boardName: "", postData: postData)

        // Verify nothing was created in any board
        let snapshot = try await db.collection("BoardInfo").document("SDR")
            .collection("Posts").getDocuments()
        XCTAssertEqual(snapshot.documents.count, 0)
    }

    // MARK: - writeComment

    func testWriteComment() async throws {
        // Seed user and a post
        try await seedDocument(collection: "Users", document: testUID, data: [
            "UserName": "Commenter"
        ])
        try await seedDocumentAtPath("BoardInfo/SDR/Posts/post1", data: [
            "PostTitle": "Post", "UserId": "someone", "UserName": "X",
            "PublishedTime": "2025-01-01", "PostType": "text",
            "BoardTap": "General", "Views": 0, "VoteUps": 0, "CommentsNumber": 0
        ])

        // Act
        try await dataSource.writeComment(
            boardName: "SDR",
            postId: "post1",
            target: "",
            text: "This is a test comment"
        )

        // Verify
        let commentsSnapshot = try await db.collection("BoardInfo")
            .document("SDR").collection("Posts").document("post1")
            .collection("BoardPostContents").document("Comments")
            .collection("CommentList")
            .getDocuments()

        XCTAssertEqual(commentsSnapshot.documents.count, 1)

        let commentData = commentsSnapshot.documents.first!.data()
        XCTAssertEqual(commentData["Text"] as? String, "This is a test comment")
        XCTAssertEqual(commentData["UserName"] as? String, "Commenter")
        XCTAssertEqual(commentData["UserId"] as? String, testUID)
        XCTAssertEqual(commentData["PostId"] as? String, "post1")
        XCTAssertEqual(commentData["IsRevised"] as? String, "No")
        XCTAssertNotNil(commentData["PublishedTime"])
    }

    // MARK: - updateUser

    func testUpdateUser() async throws {
        // Seed initial user document
        try await seedDocument(collection: "Users", document: testUID, data: [
            "UserName": "OriginalName",
            "Points": 100
        ])

        // Act — update with merge
        try await dataSource.updateUser(userInfo: [
            "UserName": "UpdatedName",
            "NewField": "NewValue"
        ])

        // Verify
        let data = try await readDocument(atPath: "Users/\(testUID!)")
        XCTAssertEqual(data?["UserName"] as? String, "UpdatedName")
        XCTAssertEqual(data?["NewField"] as? String, "NewValue")
        // Points should still be there (merge: true)
        XCTAssertEqual(data?["Points"] as? Int, 100)
    }

    func testUpdateUser_notLoggedIn() async throws {
        try Auth.auth().signOut()

        do {
            try await dataSource.updateUser(userInfo: ["UserName": "Fail"])
            XCTFail("Should have thrown when not logged in")
        } catch {
            // Expected — UserLoginFailures.LoginFailed
        }

        try await signInAsPrimaryUser()
    }

    // MARK: - voteUpPost

    func testVoteUpPost() async throws {
        // Seed a post with VoteUps = 5
        try await seedDocumentAtPath("BoardInfo/SDR/Posts/post1", data: [
            "PostTitle": "Votable Post",
            "VoteUps": 5,
            "PostType": "text", "BoardTap": "General",
            "UserId": testUID!, "UserName": "T",
            "PublishedTime": "2025-01-01", "Views": 0, "CommentsNumber": 0
        ])

        // Act
        try await dataSource.voteUpPost(boardName: "SDR", postId: "post1")

        // Verify
        let data = try await readDocument(atPath: "BoardInfo/SDR/Posts/post1")
        XCTAssertEqual(data?["VoteUps"] as? Int, 6)
    }

    func testVoteUpPost_concurrent() async throws {
        // Seed a post with VoteUps = 0
        try await seedDocumentAtPath("BoardInfo/SDR/Posts/post1", data: [
            "PostTitle": "Concurrent Vote Post",
            "VoteUps": 0,
            "PostType": "text", "BoardTap": "General",
            "UserId": testUID!, "UserName": "T",
            "PublishedTime": "2025-01-01", "Views": 0, "CommentsNumber": 0
        ])

        // Fire 3 concurrent vote-ups (testing transaction correctness)
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<3 {
                group.addTask {
                    try await self.dataSource.voteUpPost(boardName: "SDR", postId: "post1")
                }
            }
            try await group.waitForAll()
        }

        // Verify exactly 3 increments
        let data = try await readDocument(atPath: "BoardInfo/SDR/Posts/post1")
        XCTAssertEqual(data?["VoteUps"] as? Int, 3)
    }

    func testVoteUpPost_emptyInputs() async throws {
        // Should return early without error
        try await dataSource.voteUpPost(boardName: "", postId: "post1")
        try await dataSource.voteUpPost(boardName: "SDR", postId: "")
    }

    // MARK: - createReport

    func testCreateReport() async throws {
        try await dataSource.createReport(
            boardName: "SDR",
            postId: "post1",
            reason: "Spam",
            detail: "This post is spam content"
        )

        // Verify
        let reportsSnapshot = try await db.collection("Reports").getDocuments()
        XCTAssertEqual(reportsSnapshot.documents.count, 1)

        let reportData = reportsSnapshot.documents.first!.data()
        XCTAssertEqual(reportData["BoardName"] as? String, "SDR")
        XCTAssertEqual(reportData["PostId"] as? String, "post1")
        XCTAssertEqual(reportData["Reason"] as? String, "Spam")
        XCTAssertEqual(reportData["Detail"] as? String, "This post is spam content")
        XCTAssertEqual(reportData["ReporterId"] as? String, testUID)
        XCTAssertEqual(reportData["Status"] as? String, "pending")
        XCTAssertNotNil(reportData["ReportedTime"])
    }

    // MARK: - deleteUser

    func testDeleteUser() async throws {
        // Seed user document
        try await seedDocument(collection: "Users", document: testUID, data: [
            "UserName": "ToBeDeleted",
            "Points": 50
        ])

        // Verify it exists
        let before = try await readDocument(atPath: "Users/\(testUID!)")
        XCTAssertNotNil(before)

        // Act
        try await dataSource.deleteUser()

        // Verify deletion
        let after = try await readDocument(atPath: "Users/\(testUID!)")
        XCTAssertNil(after)
    }

    func testDeleteUser_notLoggedIn() async throws {
        try Auth.auth().signOut()

        do {
            try await dataSource.deleteUser()
            XCTFail("Should have thrown when not logged in")
        } catch {
            // Expected
        }

        try await signInAsPrimaryUser()
    }

    // MARK: - markNotificationRead

    func testMarkNotificationRead() async throws {
        // Seed a notification
        try await seedDocumentAtPath("Notifications/\(testUID!)/items/n1", data: [
            "title": "Test Notification",
            "timestamp": "2025-01-01 00:00:00 +0000",
            "isRead": false
        ])

        // Verify unread
        let before = try await readDocument(atPath: "Notifications/\(testUID!)/items/n1")
        XCTAssertEqual(before?["isRead"] as? Bool, false)

        // Act
        try await dataSource.markNotificationRead(notificationId: "n1")

        // Verify read
        let after = try await readDocument(atPath: "Notifications/\(testUID!)/items/n1")
        XCTAssertEqual(after?["isRead"] as? Bool, true)
        // Other fields should be preserved
        XCTAssertEqual(after?["title"] as? String, "Test Notification")
    }

    func testMarkNotificationRead_notLoggedIn() async throws {
        try Auth.auth().signOut()

        do {
            try await dataSource.markNotificationRead(notificationId: "n1")
            XCTFail("Should have thrown when not logged in")
        } catch {
            // Expected
        }

        try await signInAsPrimaryUser()
    }
}
