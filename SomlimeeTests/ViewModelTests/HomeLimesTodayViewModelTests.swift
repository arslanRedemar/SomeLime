@testable import Somlimee
import XCTest

final class HomeLimesTodayViewModelTests: XCTestCase {
    private var mockBoardRepo: MockBoardRepository!
    private var sut: HomeLimesTodayViewModelImpl!

    override func setUp() {
        super.setUp()
        mockBoardRepo = MockBoardRepository()
        sut = HomeLimesTodayViewModelImpl(boardRepo: mockBoardRepo)
    }

    func testLoadPostListPopulatesData() async {
        mockBoardRepo.getBoardPostMetaListResult = [TestFixtures.makeBoardPostMetaData()]
        await sut.loadPostList(boardName: "board1")
        XCTAssertNotNil(sut.postList)
        XCTAssertEqual(sut.postList?.list.count, 1)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadPostListNilWhenRepoReturnsNil() async {
        mockBoardRepo.getBoardPostMetaListResult = nil
        await sut.loadPostList(boardName: "board1")
        XCTAssertNil(sut.postList)
        XCTAssertFalse(sut.isLoading)
    }
}
