@testable import Somlimee
import XCTest

final class ProfileSettingsViewModelTests: XCTestCase {
    private var mockUserRepo: MockUserRepository!
    private var mockAuthRepo: MockAuthRepository!
    private var sut: ProfileSettingsViewModelImpl!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserRepository()
        mockAuthRepo = MockAuthRepository()
        sut = ProfileSettingsViewModelImpl(userRepo: mockUserRepo, authRepo: mockAuthRepo)
    }

    func testLoadProfilePopulatesNicknameAndEmail() async {
        mockUserRepo.getUserDataResult = TestFixtures.makeProfileData(userName: "Alice")
        mockAuthRepo.currentUserEmail = "alice@test.com"
        await sut.loadProfile()
        XCTAssertEqual(sut.nickname, "Alice")
        XCTAssertEqual(sut.email, "alice@test.com")
        XCTAssertFalse(sut.isLoading)
    }

    func testUpdateNicknameSuccess() async {
        sut.nickname = "NewName"
        await sut.updateNickname()
        XCTAssertNotNil(sut.successMessage)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockUserRepo.updateNicknameCallCount, 1)
        XCTAssertEqual(mockUserRepo.lastNickname, "NewName")
    }

    func testUpdateNicknameEmptyShowsError() async {
        sut.nickname = "   "
        await sut.updateNickname()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(mockUserRepo.updateNicknameCallCount, 0)
    }

    func testUpdateNicknameFailure() async {
        sut.nickname = "Valid"
        mockUserRepo.updateNicknameError = UserProfileFailures.updateNicknameFailed
        await sut.updateNickname()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNil(sut.successMessage)
    }

    func testDeleteAccountSuccess() async {
        let result = await sut.deleteAccount(email: "test@test.com", password: "pass123")
        XCTAssertTrue(result)
        XCTAssertEqual(mockAuthRepo.reauthenticateCallCount, 1)
        XCTAssertEqual(mockUserRepo.deleteUserDataCallCount, 1)
        XCTAssertEqual(mockAuthRepo.deleteAccountCallCount, 1)
    }

    func testDeleteAccountReauthFailure() async {
        mockAuthRepo.reauthenticateError = UserProfileFailures.reauthenticationRequired
        let result = await sut.deleteAccount(email: "test@test.com", password: "wrong")
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testDeleteAccountGenericFailure() async {
        mockAuthRepo.deleteAccountError = NSError(domain: "test", code: 1)
        let result = await sut.deleteAccount(email: "test@test.com", password: "pass123")
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }
}
