@testable import Somlimee
import XCTest

final class BoardRepositoryTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: BoardRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = BoardRepositoryImpl(dataSource: mockDataSource)
    }

    func testGetBoardInfoDataReturnsMappedData() async throws {
        mockDataSource.getBoardInfoDataResult = TestFixtures.makeBoardInfoDict()
        let result = try await sut.getBoardInfoData(name: "MyBoard")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.boardName, "MyBoard")
        XCTAssertEqual(result?.boardDescription, "Test Description")
        XCTAssertEqual(mockDataSource.lastBoardInfoName, "MyBoard")
    }

    func testGetBoardInfoDataReturnsNilWhenDataSourceReturnsNil() async throws {
        mockDataSource.getBoardInfoDataResult = nil
        let result = try await sut.getBoardInfoData(name: "Board")
        XCTAssertNil(result)
    }

    func testGetBoardPostMetaListReturnsMappedList() async throws {
        mockDataSource.getBoardPostMetaListResult = [TestFixtures.makeBoardPostMetaDict()]
        let result = try await sut.getBoardPostMetaList(boardName: "board1", startTime: "", counts: 10)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?[0].boardID, "board1")
        XCTAssertEqual(result?[0].postTitle, "Test Post")
    }

    func testGetBoardPostMetaListReturnsNilForNilData() async throws {
        mockDataSource.getBoardPostMetaListResult = nil
        let result = try await sut.getBoardPostMetaList(boardName: "board1", startTime: "", counts: 10)
        XCTAssertNil(result)
    }
}
