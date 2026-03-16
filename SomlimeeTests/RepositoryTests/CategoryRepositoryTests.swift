@testable import Somlimee
import XCTest

final class CategoryRepositoryTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: CategoryRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = CategoryRepositoryImpl(dataSource: mockDataSource)
    }

    func testGetCategoryDataReturnsDecodedData() async throws {
        mockDataSource.getCategoryDataResult = ["list": ["Cat1", "Cat2"]]
        let result = try await sut.getCategoryData()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.list, ["Cat1", "Cat2"])
    }

    func testGetCategoryDataReturnsNilForNilData() async throws {
        mockDataSource.getCategoryDataResult = nil
        let result = try await sut.getCategoryData()
        XCTAssertNil(result)
    }
}
