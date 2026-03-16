//
//  UserRepositoryExtendedTests.swift
//  SomlimeeTests
//

@testable import Somlimee
import XCTest

final class UserRepositoryExtendedTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: UserRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = UserRepositoryImpl(dataSource: mockDataSource)
    }

    override func tearDown() {
        mockDataSource = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Get User Posts Tests

    func testGetUserPostsReturnsDecodedPosts() async throws {
        mockDataSource.getUserPostsResult = [
            TestFixtures.makeBoardPostMetaDict(postID: "p1", title: "Post 1"),
            TestFixtures.makeBoardPostMetaDict(postID: "p2", title: "Post 2")
        ]

        let result = try await sut.getUserPosts(userId: "user1")

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].postTitle, "Post 1")
        XCTAssertEqual(result[1].postTitle, "Post 2")
        XCTAssertEqual(mockDataSource.getUserPostsCallCount, 1)
    }

    func testGetUserPostsReturnsEmptyForNil() async throws {
        mockDataSource.getUserPostsResult = nil

        let result = try await sut.getUserPosts(userId: "user1")

        XCTAssertTrue(result.isEmpty)
    }

    func testGetUserPostsReturnsSinglePost() async throws {
        mockDataSource.getUserPostsResult = [
            TestFixtures.makeBoardPostMetaDict(postID: "p1", title: "Single Post")
        ]

        let result = try await sut.getUserPosts(userId: "user1")

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].postTitle, "Single Post")
    }

    func testGetUserPostsPropagatesError() async {
        mockDataSource.errorToThrow = NSError(domain: "test", code: 1)

        do {
            _ = try await sut.getUserPosts(userId: "user1")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(mockDataSource.getUserPostsCallCount, 1)
        }
    }

    // MARK: - Get User Comments Tests

    func testGetUserCommentsReturnsDecodedComments() async throws {
        mockDataSource.getUserCommentsResult = [
            TestFixtures.makeBoardPostCommentDict(text: "Comment 1"),
            TestFixtures.makeBoardPostCommentDict(text: "Comment 2")
        ]

        let result = try await sut.getUserComments(userId: "user1")

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].text, "Comment 1")
        XCTAssertEqual(mockDataSource.getUserCommentsCallCount, 1)
    }

    func testGetUserCommentsReturnsEmptyForNil() async throws {
        mockDataSource.getUserCommentsResult = nil

        let result = try await sut.getUserComments(userId: "user1")

        XCTAssertTrue(result.isEmpty)
    }

    func testGetUserCommentsReturnsSingleComment() async throws {
        mockDataSource.getUserCommentsResult = [
            TestFixtures.makeBoardPostCommentDict(text: "Single Comment")
        ]

        let result = try await sut.getUserComments(userId: "user1")

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].text, "Single Comment")
    }

    func testGetUserCommentsPropagatesError() async {
        mockDataSource.errorToThrow = NSError(domain: "test", code: 1)

        do {
            _ = try await sut.getUserComments(userId: "user1")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(mockDataSource.getUserCommentsCallCount, 1)
        }
    }
}
