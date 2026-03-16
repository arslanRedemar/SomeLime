@testable import Somlimee
import XCTest

final class UCWriteCommentTests: XCTestCase {
    private var mockPostRepo: MockPostRepository!
    private var sut: UCWriteCommentImpl!

    override func setUp() {
        super.setUp()
        mockPostRepo = MockPostRepository()
        sut = UCWriteCommentImpl(postRepository: mockPostRepo)
    }

    func testWriteCommentSuccess() async {
        let result = await sut.writeComment(boardName: "board1", postId: "p1", target: "", text: "Hello")
        switch result {
        case .success:
            XCTAssertEqual(mockPostRepo.writeCommentCallCount, 1)
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testWriteCommentFailure() async {
        mockPostRepo.writeCommentError = NSError(domain: "test", code: 1)
        let result = await sut.writeComment(boardName: "board1", postId: "p1", target: "", text: "Hello")
        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure:
            break
        }
    }
}
