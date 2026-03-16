@testable import Somlimee
import XCTest

final class PsyTestListViewModelTests: XCTestCase {
    private var sut: PsyTestListViewModelImpl!

    override func setUp() {
        super.setUp()
        sut = PsyTestListViewModelImpl()
    }

    // MARK: - Initial State

    func testInitialState() {
        XCTAssertTrue(sut.testItems.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - loadTests

    func testLoadTestsPopulatesItems() async {
        await sut.loadTests()

        XCTAssertFalse(sut.testItems.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadTestsContainsSomLiMeTest() async {
        await sut.loadTests()

        let somlimeTest = sut.testItems.first { $0.id == "somlime_personality" }
        XCTAssertNotNil(somlimeTest)
        XCTAssertEqual(somlimeTest?.questionCount, 5)
        XCTAssertGreaterThan(somlimeTest?.estimatedMinutes ?? 0, 0)
    }

    func testLoadTestsItemHasValidProperties() async {
        await sut.loadTests()

        guard let item = sut.testItems.first else {
            XCTFail("Expected at least one test item")
            return
        }
        XCTAssertFalse(item.id.isEmpty)
        XCTAssertFalse(item.name.isEmpty)
        XCTAssertFalse(item.description.isEmpty)
        XCTAssertFalse(item.imageName.isEmpty)
        XCTAssertGreaterThan(item.questionCount, 0)
    }
}
