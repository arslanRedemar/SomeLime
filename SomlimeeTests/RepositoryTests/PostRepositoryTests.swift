@testable import Somlimee
import XCTest

final class PostRepositoryTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: PostRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = PostRepositoryImpl(dataSource: mockDataSource)
    }

    func testWriteBoardPostCallsDataSource() async throws {
        let postData = TestFixtures.makeBoardPostContentData()
        try await sut.writeBoardPost(boardName: "board1", postData: postData)
        XCTAssertEqual(mockDataSource.createPostCallCount, 1)
        XCTAssertEqual(mockDataSource.lastCreatePostBoardName, "board1")
    }

    func testWriteBoardPostWrapsError() async {
        mockDataSource.createPostError = NSError(domain: "test", code: 1)
        do {
            try await sut.writeBoardPost(boardName: "board1", postData: TestFixtures.makeBoardPostContentData())
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is DataSourceFailures)
        }
    }

    func testGetBoardPostMetaReturnsMappedData() async throws {
        mockDataSource.getBoardPostMetaResult = TestFixtures.makeBoardPostMetaDict()
        let result = try await sut.getBoardPostMeta(boardName: "board1", postId: "p1")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.boardID, "board1")
        XCTAssertEqual(result?.postTitle, "Test Post")
    }

    func testGetBoardPostContentCallsBothMetaAndContent() async throws {
        mockDataSource.getBoardPostContentResult = [["Text": "Hello paragraph"]]
        mockDataSource.getBoardPostMetaResult = [
            "BoardTap": "General",
            "UserId": "user1",
            "PostTitle": "Test Title"
        ]
        let result = try await sut.getBoardPostContent(boardName: "board1", postId: "p1")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.boardPostTitle, "Test Title")
        XCTAssertEqual(result?.boardPostParagraph, "Hello paragraph")
        XCTAssertEqual(mockDataSource.getBoardPostContentCallCount, 1)
        XCTAssertEqual(mockDataSource.getBoardPostMetaCallCount, 1)
    }

    func testGetBoardPostContentReturnsNilWhenContentIsNil() async throws {
        mockDataSource.getBoardPostContentResult = nil
        let result = try await sut.getBoardPostContent(boardName: "board1", postId: "p1")
        XCTAssertNil(result)
    }

    func testGetCommentsReturnsDecodedComments() async throws {
        mockDataSource.getCommentsResult = [TestFixtures.makeBoardPostCommentDict()]
        let result = try await sut.getComments(boardName: "board1", postId: "p1")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].userName, "TestUser")
    }

    func testGetCommentsReturnsEmptyForNilData() async throws {
        mockDataSource.getCommentsResult = nil
        let result = try await sut.getComments(boardName: "board1", postId: "p1")
        XCTAssertTrue(result.isEmpty)
    }

    func testWriteComment() async throws {
        try await sut.writeComment(boardName: "board1", postId: "p1", target: "", text: "Hi")
        XCTAssertEqual(mockDataSource.writeCommentCallCount, 1)
        XCTAssertEqual(mockDataSource.lastWriteCommentText, "Hi")
    }
}
