@testable import Somlimee
import XCTest

final class UCGetPostTests: XCTestCase {
    private var mockPostRepo: MockPostRepository!
    private var sut: UCGetPostImpl!

    override func setUp() {
        super.setUp()
        mockPostRepo = MockPostRepository()
        sut = UCGetPostImpl(postRepository: mockPostRepo)
    }

    func testGetPostMetaSuccess() async {
        mockPostRepo.getBoardPostMetaResult = TestFixtures.makeBoardPostMetaData()
        let result = await sut.getPostMeta(boardName: "board1", postId: "p1")
        switch result {
        case .success(let meta):
            XCTAssertEqual(meta.title, "Test Post")
            XCTAssertEqual(meta.postID, "post1")
            XCTAssertEqual(meta.boardName, "board1")
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testGetPostMetaFailsForNilData() async {
        mockPostRepo.getBoardPostMetaResult = nil
        let result = await sut.getPostMeta(boardName: "board1", postId: "p1")
        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCGetPostFailures)
        }
    }

    func testGetPostContentSuccess() async {
        mockPostRepo.getBoardPostContentResult = TestFixtures.makeBoardPostContentData()
        let result = await sut.getPostContent(boardName: "board1", postId: "p1")
        switch result {
        case .success(let content):
            XCTAssertEqual(content.paragraph, "Test paragraph")
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testGetPostContentFailsForNilData() async {
        mockPostRepo.getBoardPostContentResult = nil
        let result = await sut.getPostContent(boardName: "board1", postId: "p1")
        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCGetPostFailures)
        }
    }
}
