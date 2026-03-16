@testable import Somlimee
import XCTest

final class UCGetMyLimeRoomPostListTests: XCTestCase {
    private var mockUserRepo: MockUserRepository!
    private var mockBoardRepo: MockBoardRepository!
    private var sut: UCGetMyLimeRoomPostListImpl!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserRepository()
        mockBoardRepo = MockBoardRepository()
        sut = UCGetMyLimeRoomPostListImpl(boardRepository: mockBoardRepo, userRepository: mockUserRepo)
    }

    func testGetMyLimeRoomPostListSuccess() async {
        mockUserRepo.getUserDataResult = TestFixtures.makeProfileData(personalityType: "SDD")
        mockBoardRepo.getBoardPostMetaListResult = [TestFixtures.makeBoardPostMetaData()]
        let result = await sut.getMyLimeRoomPostList()
        switch result {
        case .success(let postList):
            XCTAssertEqual(postList.list.count, 1)
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testGetMyLimeRoomPostListFailsForNilUser() async {
        mockUserRepo.getUserDataResult = nil
        let result = await sut.getMyLimeRoomPostList()
        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCGetMyLimeRoomPostListFailures)
        }
    }

    func testGetMyLimeRoomPostListFailsForNilPosts() async {
        mockUserRepo.getUserDataResult = TestFixtures.makeProfileData()
        mockBoardRepo.getBoardPostMetaListResult = nil
        let result = await sut.getMyLimeRoomPostList()
        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCGetMyLimeRoomPostListFailures)
        }
    }
}
