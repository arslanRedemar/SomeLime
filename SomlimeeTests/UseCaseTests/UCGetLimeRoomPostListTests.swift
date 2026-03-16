@testable import Somlimee
import XCTest

final class UCGetLimeRoomPostListTests: XCTestCase {
    private var mockBoardRepo: MockBoardRepository!
    private var sut: UCGetLimeRoomPostListImpl!

    override func setUp() {
        super.setUp()
        mockBoardRepo = MockBoardRepository()
        sut = UCGetLimeRoomPostListImpl(boardRepository: mockBoardRepo)
    }

    func testGetLimeRoomPostListSuccess() async {
        mockBoardRepo.getBoardPostMetaListResult = [TestFixtures.makeBoardPostMetaData()]
        let result = await sut.getLimeRoomPostList(boardName: "board1", tabName: "", counts: 10)
        switch result {
        case .success(let postList):
            XCTAssertEqual(postList.list.count, 1)
            XCTAssertEqual(postList.list[0].title, "Test Post")
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testGetLimeRoomPostListFailsForNilData() async {
        mockBoardRepo.getBoardPostMetaListResult = nil
        let result = await sut.getLimeRoomPostList(boardName: "board1", tabName: "", counts: 10)
        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCGetMyLimeRoomPostListFailures)
        }
    }
}
