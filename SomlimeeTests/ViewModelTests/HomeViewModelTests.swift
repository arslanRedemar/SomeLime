@testable import Somlimee
import XCTest

final class HomeViewModelTests: XCTestCase {
    private var mockRealTimeRepo: MockRealTimeRepository!
    private var mockBoardRepo: MockBoardRepository!
    private var mockUserRepo: MockUserRepository!
    private var mockAuthRepo: MockAuthRepository!
    private var sut: HomeViewModelImpl!

    override func setUp() {
        super.setUp()
        mockRealTimeRepo = MockRealTimeRepository()
        mockBoardRepo = MockBoardRepository()
        mockUserRepo = MockUserRepository()
        mockAuthRepo = MockAuthRepository()
        sut = HomeViewModelImpl(realTimeRepo: mockRealTimeRepo, boardRepo: mockBoardRepo, userRepo: mockUserRepo, authRepo: mockAuthRepo)
    }

    func testLoadTrendsPopulatesTrends() async {
        mockRealTimeRepo.getLimeTrendsDataResult = TestFixtures.makeLimeTrendsData()
        await sut.loadTrends()
        XCTAssertNotNil(sut.trends)
        XCTAssertEqual(sut.trends?.list, ["trend1", "trend2"])
    }

    func testLoadTrendsNilWhenRepoReturnsNil() async {
        mockRealTimeRepo.getLimeTrendsDataResult = nil
        await sut.loadTrends()
        XCTAssertNil(sut.trends)
    }

    func testLoadUserTypeName() async {
        mockUserRepo.getUserDataResult = TestFixtures.makeProfileData(personalityType: "SDD")
        await sut.loadUserTypeName()
        XCTAssertEqual(sut.userTypeName?.name, "SDD")
    }

    func testLoadUserStatus() async {
        mockUserRepo.isUserLoggedInResult = true
        await sut.loadUserStatus()
        XCTAssertEqual(sut.userStatus?.isLoggedIn, true)
    }

    func testLoadMyLimeRoomPostsList() async {
        mockBoardRepo.getBoardPostMetaListResult = [TestFixtures.makeBoardPostMetaData()]
        await sut.loadMyLimeRoomPostsList(limeRoomName: "SDD")
        XCTAssertNotNil(sut.myLimeRoomPostList)
        XCTAssertEqual(sut.myLimeRoomPostList?.list.count, 1)
    }

    func testLoadLimeRoomList() async {
        await sut.loadLimeRoomList()
        XCTAssertNotNil(sut.limeRoomList)
    }

    func testLoadPsyTestList() async {
        await sut.loadPsyTestList()
        XCTAssertNotNil(sut.psyTestList)
    }

    func testSetUserStatusChangeListener() {
        var receivedID: String?
        mockAuthRepo.currentUserID = "user1"
        sut.setUserStatusChangeListener { id in
            receivedID = id
        }
        XCTAssertEqual(mockAuthRepo.addAuthStateListenerCallCount, 1)
        XCTAssertEqual(receivedID, "user1")
    }
}
