@testable import Somlimee
import XCTest

final class ChangePasswordViewModelTests: XCTestCase {
    private var mockAuthRepo: MockAuthRepository!
    private var sut: ChangePasswordViewModelImpl!

    override func setUp() {
        super.setUp()
        mockAuthRepo = MockAuthRepository()
        sut = ChangePasswordViewModelImpl(authRepo: mockAuthRepo)
    }

    func testChangePasswordSuccess() async {
        let result = await sut.changePassword(email: "test@test.com", currentPassword: "old123", newPassword: "new123", confirmPassword: "new123")
        XCTAssertTrue(result)
        XCTAssertNotNil(sut.successMessage)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockAuthRepo.reauthenticateCallCount, 1)
        XCTAssertEqual(mockAuthRepo.updatePasswordCallCount, 1)
        XCTAssertEqual(mockAuthRepo.lastNewPassword, "new123")
    }

    func testChangePasswordMismatch() async {
        let result = await sut.changePassword(email: "test@test.com", currentPassword: "old123", newPassword: "new123", confirmPassword: "different")
        XCTAssertFalse(result)
        XCTAssertEqual(sut.errorMessage, "New passwords do not match.")
        XCTAssertEqual(mockAuthRepo.reauthenticateCallCount, 0)
    }

    func testChangePasswordTooShort() async {
        let result = await sut.changePassword(email: "test@test.com", currentPassword: "old123", newPassword: "ab", confirmPassword: "ab")
        XCTAssertFalse(result)
        XCTAssertEqual(sut.errorMessage, "Password must be at least 6 characters.")
        XCTAssertEqual(mockAuthRepo.reauthenticateCallCount, 0)
    }

    func testChangePasswordReauthFailure() async {
        mockAuthRepo.reauthenticateError = UserProfileFailures.reauthenticationRequired
        let result = await sut.changePassword(email: "test@test.com", currentPassword: "wrong", newPassword: "new123", confirmPassword: "new123")
        XCTAssertFalse(result)
        XCTAssertEqual(sut.errorMessage, "Current password is incorrect.")
    }

    func testChangePasswordGenericFailure() async {
        mockAuthRepo.updatePasswordError = NSError(domain: "test", code: 1)
        let result = await sut.changePassword(email: "test@test.com", currentPassword: "old123", newPassword: "new123", confirmPassword: "new123")
        XCTAssertFalse(result)
        XCTAssertEqual(sut.errorMessage, "Failed to update password.")
    }
}
