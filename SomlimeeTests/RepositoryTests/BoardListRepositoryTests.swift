@testable import Somlimee
import XCTest

final class BoardListRepositoryTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: BoardListRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = BoardListRepositoryImpl(dataSource: mockDataSource)
    }

    func testGetBoardListDataReturnsList() async throws {
        mockDataSource.getBoardListDataResult = ["list": ["Board1", "Board2"]]
        let result = try await sut.getBoardListData()
        XCTAssertEqual(result, ["Board1", "Board2"])
    }

    func testGetBoardListDataReturnsNilForNilData() async throws {
        mockDataSource.getBoardListDataResult = nil
        let result = try await sut.getBoardListData()
        XCTAssertNil(result)
    }

    func testGetBoardListDataReturnsNilForMissingKey() async throws {
        mockDataSource.getBoardListDataResult = ["other": "value"]
        let result = try await sut.getBoardListData()
        XCTAssertNil(result)
    }
}
