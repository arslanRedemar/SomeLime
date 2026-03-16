@testable import Somlimee
import XCTest

final class PersonalityTestRepositoryTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: PersonalityTestRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = PersonalityTestRepositoryImpl(dataSource: mockDataSource)
    }

    func testGetPersonalityTestResultReturnsData() async throws {
        mockDataSource.getUserDataResult = TestFixtures.makeProfileDict()
        let result = try await sut.getPersonalityTestResult()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.Strenuousness, 10)
        XCTAssertEqual(result?.type, "SDD")
    }

    func testGetPersonalityTestResultReturnsNilForNilUserData() async throws {
        mockDataSource.getUserDataResult = nil
        let result = try await sut.getPersonalityTestResult()
        XCTAssertNil(result)
    }

    func testUpdatePersonalityTestUpdatesUserData() async throws {
        mockDataSource.getUserDataResult = TestFixtures.makeProfileDict()
        let test = TestFixtures.makePersonalityTestResult()
        try await sut.updatePersonalityTest(test: test, uid: "user1")
        XCTAssertEqual(mockDataSource.getUserDataCallCount, 1)
        XCTAssertEqual(mockDataSource.updateUserCallCount, 1)
        let sentData = mockDataSource.lastUpdateUserInfo
        XCTAssertEqual(sentData?["PersonalityType"] as? String, "SDD")
    }
}
