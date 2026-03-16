@testable import Somlimee
import XCTest

final class AppStateRepositoryTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: AppStateRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = AppStateRepositoryImpl(dataSource: mockDataSource)
    }

    func testAppStatesInitCallsDataSource() async throws {
        try await sut.appStatesInit()
        XCTAssertEqual(mockDataSource.appStatesInitCallCount, 1)
    }

    func testUpdateAppStatesCallsDataSource() async throws {
        let states = AppStatesData(isFirstTimeLaunched: true, isNeedToUpdateLocalDataSource: false)
        try await sut.updateAppStates(appStates: states)
        XCTAssertEqual(mockDataSource.updateAppStatesCallCount, 1)
    }
}
