@testable import Somlimee
import XCTest

final class ProfileViewModelTests: XCTestCase {
    private var mockUserRepo: MockUserRepository!
    private var mockPersonalityTestRepo: MockPersonalityTestRepository!
    private var mockAuthRepo: MockAuthRepository!
    private var sut: ProfileViewModelImpl!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserRepository()
        mockPersonalityTestRepo = MockPersonalityTestRepository()
        mockAuthRepo = MockAuthRepository()
        sut = ProfileViewModelImpl(userRepo: mockUserRepo, personalityTestRepo: mockPersonalityTestRepo, authRepo: mockAuthRepo)
    }

    func testLoadProfilePopulatesUserProfile() async {
        mockUserRepo.getUserDataResult = TestFixtures.makeProfileData()
        mockAuthRepo.isLoggedIn = true
        mockAuthRepo.currentUserID = "user1"
        await sut.loadProfile()
        XCTAssertNotNil(sut.userProfile)
        XCTAssertEqual(sut.userProfile?.userName, "TestUser")
        XCTAssertEqual(sut.userProfile?.userID, "user1")
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadProfileNilWhenRepoReturnsNil() async {
        mockUserRepo.getUserDataResult = nil
        await sut.loadProfile()
        XCTAssertNil(sut.userProfile)
    }

    func testLoadTestResult() async {
        mockPersonalityTestRepo.getPersonalityTestResultResult = TestFixtures.makePersonalityTestResult()
        await sut.loadTestResult()
        XCTAssertNotNil(sut.testResult)
        XCTAssertEqual(sut.testResult?.str, 10)
        XCTAssertEqual(sut.testResult?.typeName, "SDD")
    }

    func testLoadTestReport() async {
        mockPersonalityTestRepo.getPersonalityTestResultResult = TestFixtures.makePersonalityTestResult()
        await sut.loadTestReport()
        XCTAssertNotNil(sut.testReport)
        XCTAssertEqual(sut.testReport?.typeName, "SDD")
    }

    func testSignOutClearsState() async {
        mockUserRepo.getUserDataResult = TestFixtures.makeProfileData()
        mockAuthRepo.isLoggedIn = true
        mockAuthRepo.currentUserID = "user1"
        await sut.loadProfile()
        XCTAssertNotNil(sut.userProfile)

        sut.signOut()
        XCTAssertNil(sut.userProfile)
        XCTAssertNil(sut.testResult)
        XCTAssertNil(sut.testReport)
        XCTAssertEqual(mockAuthRepo.signOutCallCount, 1)
    }
}
