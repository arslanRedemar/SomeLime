@testable import Somlimee
import XCTest

final class UCGetCommentsTests: XCTestCase {
    private var mockPostRepo: MockPostRepository!
    private var sut: UCGetCommentsImpl!

    override func setUp() {
        super.setUp()
        mockPostRepo = MockPostRepository()
        sut = UCGetCommentsImpl(postRepository: mockPostRepo)
    }

    func testGetCommentsSuccess() async {
        mockPostRepo.getCommentsResult = [TestFixtures.makeBoardPostCommentData()]
        let result = await sut.getComments(boardName: "board1", postId: "p1")
        switch result {
        case .success(let comments):
            XCTAssertEqual(comments.count, 1)
            XCTAssertEqual(comments[0].text, "Test comment")
            XCTAssertEqual(comments[0].userName, "TestUser")
            XCTAssertFalse(comments[0].isRevised)
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testGetCommentsReturnsEmptyForEmptyData() async {
        mockPostRepo.getCommentsResult = []
        let result = await sut.getComments(boardName: "board1", postId: "p1")
        switch result {
        case .success(let comments):
            XCTAssertTrue(comments.isEmpty)
        case .failure:
            XCTFail("Expected success")
        }
    }
}
