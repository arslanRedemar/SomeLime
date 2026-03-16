@testable import Somlimee
import XCTest

final class LimeRoomViewModelTests: XCTestCase {
    private var mockGetMeta: MockUCGetLimeRoomMeta!
    private var mockGetPostList: MockUCGetLimeRoomPostList!
    private var mockUserRepo: MockUserRepository!
    private var sut: LimeRoomViewModelImpl!

    override func setUp() {
        super.setUp()
        mockGetMeta = MockUCGetLimeRoomMeta()
        mockGetPostList = MockUCGetLimeRoomPostList()
        mockUserRepo = MockUserRepository()
        sut = LimeRoomViewModelImpl(getLimeRoomMeta: mockGetMeta, getLimeRoomPostList: mockGetPostList, userRepo: mockUserRepo)
    }

    func testLoadMetaSuccess() async {
        mockGetMeta.getLimeRoomMetaResult = .success(TestFixtures.makeLimeRoomMeta(name: "Room1"))
        await sut.loadMeta(boardName: "Room1")
        XCTAssertNotNil(sut.meta)
        XCTAssertEqual(sut.meta?.limeRoomName, "Room1")
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadMetaFailure() async {
        mockGetMeta.getLimeRoomMetaResult = .failure(UCGetMyLimeRoomMetaFailures.EmptyLimeRoom)
        await sut.loadMeta(boardName: "Room1")
        XCTAssertNil(sut.meta)
    }

    func testLoadPostListSuccess() async {
        let postList = LimeRoomPostList(list: [TestFixtures.makeLimeRoomPostMeta()])
        mockGetPostList.getLimeRoomPostListResult = .success(postList)
        await sut.loadPostList(boardName: "Room1", page: 0)
        XCTAssertNotNil(sut.postList)
        XCTAssertEqual(sut.postList?.list.count, 1)
    }

    func testLoadPostListFailure() async {
        mockGetPostList.getLimeRoomPostListResult = .failure(UCGetMyLimeRoomPostListFailures.EmptyPostList)
        await sut.loadPostList(boardName: "Room1", page: 0)
        XCTAssertNil(sut.postList)
    }
}
