//
//  PostRepositoryVoteUpTests.swift
//  SomlimeeTests
//

@testable import Somlimee
import XCTest

final class PostRepositoryVoteUpTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: PostRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = PostRepositoryImpl(dataSource: mockDataSource)
    }

    override func tearDown() {
        mockDataSource = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Vote Up Tests

    func testVoteUpPostCallsDataSource() async throws {
        try await sut.voteUpPost(boardName: "board1", postId: "p1")

        XCTAssertEqual(mockDataSource.voteUpPostCallCount, 1)
        XCTAssertEqual(mockDataSource.lastVoteUpBoardName, "board1")
        XCTAssertEqual(mockDataSource.lastVoteUpPostId, "p1")
    }

    func testVoteUpPostWithDifferentData() async throws {
        try await sut.voteUpPost(boardName: "myLimeRoom", postId: "post123")

        XCTAssertEqual(mockDataSource.voteUpPostCallCount, 1)
        XCTAssertEqual(mockDataSource.lastVoteUpBoardName, "myLimeRoom")
        XCTAssertEqual(mockDataSource.lastVoteUpPostId, "post123")
    }

    func testVoteUpPostPropagatesError() async {
        mockDataSource.voteUpPostError = NSError(domain: "test", code: 1)

        do {
            try await sut.voteUpPost(boardName: "board1", postId: "p1")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(mockDataSource.voteUpPostCallCount, 1)
        }
    }

    // MARK: - Upload Image Tests

    func testUploadImageCallsDataSource() async throws {
        mockDataSource.uploadImageResult = "https://example.com/test.jpg"

        let result = try await sut.uploadImage(data: Data([1, 2, 3]), path: "test/path.jpg")

        XCTAssertEqual(result, "https://example.com/test.jpg")
        XCTAssertEqual(mockDataSource.uploadImageCallCount, 1)
    }

    func testUploadImageWithDifferentPath() async throws {
        mockDataSource.uploadImageResult = "https://storage.com/images/photo.png"

        let result = try await sut.uploadImage(data: Data([0xFF, 0xD8]), path: "posts/user1/image.png")

        XCTAssertEqual(result, "https://storage.com/images/photo.png")
        XCTAssertEqual(mockDataSource.uploadImageCallCount, 1)
    }

    func testUploadImagePropagatesError() async {
        mockDataSource.errorToThrow = NSError(domain: "test", code: 1)

        do {
            _ = try await sut.uploadImage(data: Data([1, 2, 3]), path: "test/path.jpg")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(mockDataSource.uploadImageCallCount, 1)
        }
    }
}
