@testable import Somlimee
import XCTest

final class UCGetLimeRoomMetaTests: XCTestCase {
    private var mockBoardRepo: MockBoardRepository!
    private var sut: UCGetLimeRoomMetaImpl!

    override func setUp() {
        super.setUp()
        mockBoardRepo = MockBoardRepository()
        sut = UCGetLimeRoomMetaImpl(boardRepository: mockBoardRepo)
    }

    func testGetLimeRoomMetaSuccess() async {
        mockBoardRepo.getBoardInfoDataResult = TestFixtures.makeBoardInfoData(boardName: "Room1", description: "Desc")
        let result = await sut.getLimeRoomMeta(boardName: "Room1")
        switch result {
        case .success(let meta):
            XCTAssertEqual(meta.limeRoomName, "Room1")
            XCTAssertEqual(meta.limeRoomDescription, "Desc")
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testGetLimeRoomMetaFailsForNilBoardInfo() async {
        mockBoardRepo.getBoardInfoDataResult = nil
        let result = await sut.getLimeRoomMeta(boardName: "Room1")
        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCGetMyLimeRoomMetaFailures)
        }
    }
}
