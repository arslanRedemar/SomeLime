@testable import Somlimee
import XCTest

final class RealTimeRepositoryTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: RealTimeRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = RealTimeRepositoryImpl(dataSource: mockDataSource)
    }

    func testGetLimeTrendsDataReturnsMappedData() async throws {
        mockDataSource.getLimeTrendsDataResult = TestFixtures.makeLimeTrendsDict()
        let result = try await sut.getLimeTrendsData()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.trendsList, ["trend1", "trend2"])
    }

    func testGetLimeTrendsDataReturnsNilForNilData() async throws {
        mockDataSource.getLimeTrendsDataResult = nil
        let result = try await sut.getLimeTrendsData()
        XCTAssertNil(result)
    }

    func testGetBoardHotPostsListFetchesMetaForEachId() async throws {
        mockDataSource.getBoardHotPostsListResult = ["post1", "post2"]
        mockDataSource.getBoardPostMetaHandler = { boardName, postId in
            var dict = TestFixtures.makeBoardPostMetaDict(postID: postId, title: "Title \(postId)")
            dict["PostId"] = postId
            return dict
        }

        let result = try await sut.getBoardHotPostsList(boardName: "board1", startTime: "", counts: 5)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
        XCTAssertEqual(result?[0].postID, "post1")
        XCTAssertEqual(result?[1].postID, "post2")
        XCTAssertEqual(result?[0].boardID, "board1")
    }

    func testGetBoardHotPostsListReturnsNilForNilData() async throws {
        mockDataSource.getBoardHotPostsListResult = nil
        let result = try await sut.getBoardHotPostsList(boardName: "board1", startTime: "", counts: 5)
        XCTAssertNil(result)
    }
}
