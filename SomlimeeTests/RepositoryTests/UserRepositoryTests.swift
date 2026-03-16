@testable import Somlimee
import XCTest

final class UserRepositoryTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: UserRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = UserRepositoryImpl(dataSource: mockDataSource)
    }

    func testGetUserDataReturnsProfileData() async throws {
        mockDataSource.getUserDataResult = TestFixtures.makeProfileDict()
        let result = try await sut.getUserData()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.userName, "TestUser")
        XCTAssertEqual(result?.personalityType, "SDD")
        XCTAssertEqual(mockDataSource.getUserDataCallCount, 1)
    }

    func testGetUserDataReturnsNilWhenDataSourceReturnsNil() async throws {
        mockDataSource.getUserDataResult = nil
        let result = try await sut.getUserData()
        XCTAssertNil(result)
    }

    func testIsUserLoggedIn() async throws {
        mockDataSource.isUserLoggedInResult = true
        let result = try await sut.isUserLoggedIn()
        XCTAssertTrue(result)
        XCTAssertEqual(mockDataSource.isUserLoggedInCallCount, 1)
    }

    func testUpdateNicknameSendsCorrectDict() async throws {
        try await sut.updateNickname("NewName")
        XCTAssertEqual(mockDataSource.updateUserCallCount, 1)
        XCTAssertEqual(mockDataSource.lastUpdateUserInfo?["UserName"] as? String, "NewName")
    }

    func testDeleteUserData() async throws {
        try await sut.deleteUserData()
        XCTAssertEqual(mockDataSource.deleteUserCallCount, 1)
    }
}
