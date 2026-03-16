@testable import Somlimee
import XCTest

final class UCGetMyLimeRoomMetaTests: XCTestCase {
    private var mockUserRepo: MockUserRepository!
    private var mockBoardRepo: MockBoardRepository!
    private var sut: UCGetMyLimeRoomMetaImpl!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserRepository()
        mockBoardRepo = MockBoardRepository()
        sut = UCGetMyLimeRoomMetaImpl(userRepository: mockUserRepo, boardRepository: mockBoardRepo)
    }

    func testGetMyLimeRoomSuccess() async {
        mockUserRepo.getUserDataResult = TestFixtures.makeProfileData(personalityType: "SDD")
        mockBoardRepo.getBoardInfoDataResult = TestFixtures.makeBoardInfoData(boardName: "SDD")
        let result = await sut.getMyLimeRoom()
        switch result {
        case .success(let meta):
            XCTAssertEqual(meta.limeRoomName, "SDD")
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testGetMyLimeRoomFailsForNilUser() async {
        mockUserRepo.getUserDataResult = nil
        let result = await sut.getMyLimeRoom()
        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCGetMyLimeRoomMetaFailures)
        }
    }

    func testGetMyLimeRoomFailsForNilBoardInfo() async {
        mockUserRepo.getUserDataResult = TestFixtures.makeProfileData()
        mockBoardRepo.getBoardInfoDataResult = nil
        let result = await sut.getMyLimeRoom()
        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCGetMyLimeRoomMetaFailures)
        }
    }
}
