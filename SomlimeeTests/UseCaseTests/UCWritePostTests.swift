@testable import Somlimee
import XCTest

final class UCWritePostTests: XCTestCase {
    private var mockPostRepo: MockPostRepository!
    private var sut: UCWritePostImpl!

    override func setUp() {
        super.setUp()
        mockPostRepo = MockPostRepository()
        sut = UCWritePostImpl(postRepository: mockPostRepo)
    }

    func testWritePostSuccess() async {
        let content = TestFixtures.makeLimeRoomPostContent()
        let meta = TestFixtures.makeLimeRoomPostMeta()
        let result = await sut.writePost(boardName: "board1", postContents: content, postMeta: meta)
        switch result {
        case .success:
            XCTAssertEqual(mockPostRepo.writeBoardPostCallCount, 1)
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testWritePostFailure() async {
        mockPostRepo.writeBoardPostError = DataSourceFailures.CouldNotWritePost
        let content = TestFixtures.makeLimeRoomPostContent()
        let meta = TestFixtures.makeLimeRoomPostMeta()
        let result = await sut.writePost(boardName: "board1", postContents: content, postMeta: meta)
        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is DataSourceFailures)
        }
    }
}
